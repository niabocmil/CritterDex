import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart';

/// One scientific-name candidate from GBIF's taxonomic database, shown as a
/// suggestion while typing a specimen's species.
class SpeciesSuggestion {
  SpeciesSuggestion({
    required this.name,
    this.rank,
    this.family,
    this.order,
  });

  final String name;
  final String? rank;
  final String? family;
  final String? order;

  /// Secondary line shown under [name] in the suggestions list, e.g.
  /// "Lucanidae · Coleoptera" — helps disambiguate same-genus results.
  String? get subtitle {
    final parts = [family, order].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// Best-effort wiki data for one species, fetched once at "unlock" time (or
/// on manual refresh) and stored straight into [SpeciesInfo] — never
/// re-fetched automatically, matching the app's fully-offline-after-that
/// philosophy for everything else it stores.
///
/// [SpeciesInfos.specialNotes] (care/husbandry specifics with no real wiki
/// equivalent) has no counterpart here and stays a manual-only field.
class SpeciesWikiResult {
  SpeciesWikiResult({
    this.description,
    this.region,
    this.lengthRangeText,
    this.temperatureRangeText,
    this.photoUrl,
    this.sourceUrl,
    this.gbifUrl,
  });

  final String? description;
  final String? region;
  final String? lengthRangeText;
  final String? temperatureRangeText;
  final String? photoUrl;
  final String? sourceUrl;
  final String? gbifUrl;
}

/// Looks up scientific names and reference info from two free, keyless,
/// open data sources: GBIF (the Global Biodiversity Information Facility)
/// for taxonomically-accurate name search, and Wikipedia for the
/// description/photo/distribution/size/temperature shown on a species'
/// Collected Species page.
///
/// Both are best-effort: every network call is wrapped so a slow/failed
/// request (or no connectivity at all) never throws past this class —
/// callers get an empty list / null instead, and the rest of the app
/// (adding a specimen, unlocking a species) proceeds exactly as if the
/// species just doesn't have wiki data (yet).
class SpeciesLookupService {
  static const _timeout = Duration(seconds: 8);

  /// Search-as-you-type scientific name suggestions via GBIF's species
  /// suggest endpoint. No API key required; GBIF is a public taxonomic
  /// database, not Wikipedia itself, so this can return good candidates for
  /// species too obscure to have a Wikipedia article at all.
  Future<List<SpeciesSuggestion>> searchNames(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];
    try {
      final uri = Uri.https('api.gbif.org', '/v1/species/suggest', {
        'q': trimmed,
        'limit': '8',
      });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return [];
      final results = jsonDecode(response.body) as List<dynamic>;
      final seen = <String>{};
      final suggestions = <SpeciesSuggestion>[];
      for (final entry in results) {
        final map = entry as Map<String, dynamic>;
        final name = (map['canonicalName'] ?? map['scientificName']) as String?;
        if (name == null || name.isEmpty || !seen.add(name)) continue;
        suggestions.add(SpeciesSuggestion(
          name: name,
          rank: map['rank'] as String?,
          family: map['family'] as String?,
          order: map['order'] as String?,
        ));
      }
      return suggestions;
    } catch (_) {
      return [];
    }
  }

  /// Fetches a best-effort description/photo/source link (from Wikipedia's
  /// REST summary API, i.e. just the lead paragraph) plus distribution/size/
  /// temperature (from the full article body, via section lookup — that
  /// detail generally lives well past the lead paragraph, in "Distribution"/
  /// "Description" sections or scattered mentions of degrees), plus a link
  /// to the species' GBIF page. Wikipedia and GBIF are looked up
  /// independently — a species obscure enough to have no Wikipedia article
  /// can still get a GBIF link, and vice versa. Returns null only if
  /// *neither* source found anything at all.
  Future<SpeciesWikiResult?> fetchWikiSummary(String species) async {
    final title = species.trim().replaceAll(' ', '_');
    String? description;
    String? photoUrl;
    String? sourceUrl;
    String? region;
    String? lengthRangeText;
    String? temperatureRangeText;

    if (title.isNotEmpty) {
      try {
        final uri = Uri.https(
            'en.wikipedia.org', '/api/rest_v1/page/summary/$title');
        final response = await http.get(uri).timeout(_timeout);
        if (response.statusCode == 200) {
          final map = jsonDecode(response.body) as Map<String, dynamic>;
          if (map['type'] != 'disambiguation') {
            final extract = map['extract'] as String?;
            final thumbnail = map['thumbnail'] as Map<String, dynamic>?;
            final pageUrl =
                (map['content_urls'] as Map<String, dynamic>?)?['desktop']
                    as Map<String, dynamic>?;
            description = (extract == null || extract.isEmpty) ? null : extract;
            photoUrl = thumbnail?['source'] as String?;
            sourceUrl = pageUrl?['page'] as String?;

            final fullText = await _fetchFullArticleText(title);
            final sections =
                fullText == null ? const <String, String>{} : _parseSections(fullText);
            region = _findRegion(sections, extract);
            lengthRangeText = _findLength(sections, fullText);
            temperatureRangeText = _findTemperature(fullText);
          }
        }
      } catch (_) {
        // Wikipedia data just stays null — GBIF (below) may still work.
      }
    }

    final gbifUrl = await _fetchGbifUrl(species);

    if (description == null &&
        photoUrl == null &&
        sourceUrl == null &&
        region == null &&
        lengthRangeText == null &&
        temperatureRangeText == null &&
        gbifUrl == null) {
      return null;
    }

    return SpeciesWikiResult(
      description: description,
      region: region,
      lengthRangeText: lengthRangeText,
      temperatureRangeText: temperatureRangeText,
      photoUrl: photoUrl,
      sourceUrl: sourceUrl,
      gbifUrl: gbifUrl,
    );
  }

  /// Resolves [species] to its GBIF backbone taxon key via their name-match
  /// API (a single best-match lookup, unlike [searchNames]' multi-candidate
  /// suggest endpoint) and builds a link to that species' GBIF page. Null on
  /// no connectivity, or if GBIF couldn't match the name to a real species
  /// (a bare genus/higher-rank match isn't precise enough to link to).
  Future<String?> _fetchGbifUrl(String species) async {
    final name = species.trim();
    if (name.isEmpty) return null;
    try {
      final uri = Uri.https('api.gbif.org', '/v1/species/match', {'name': name});
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final matchType = map['matchType'] as String?;
      if (matchType == null || matchType == 'NONE' || matchType == 'HIGHERRANK') {
        return null;
      }
      final usageKey = map['usageKey'];
      if (usageKey == null) return null;
      return 'https://www.gbif.org/species/$usageKey';
    } catch (_) {
      return null;
    }
  }

  /// The full article as plain text (not just the lead paragraph), via
  /// MediaWiki's classic action API — `exsectionformat=plain` keeps each
  /// section's heading as its own line so [_parseSections] can split on it.
  Future<String?> _fetchFullArticleText(String title) async {
    try {
      final uri = Uri.https('en.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'prop': 'extracts',
        'explaintext': '1',
        'exsectionformat': 'plain',
        'titles': title,
        'format': 'json',
      });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final pages =
          (map['query'] as Map<String, dynamic>?)?['pages'] as Map<String, dynamic>?;
      if (pages == null || pages.isEmpty) return null;
      return (pages.values.first as Map<String, dynamic>)['extract'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Splits `explaintext` output into a lowercased-heading -> body map.
  /// Section headings come out as a lone line preceded by a blank-line
  /// run (`\n\n\n`) and followed immediately (single `\n`) by their body,
  /// e.g. "...Dynastinae.\n\n\nDistribution\nThis species is widespread...".
  /// Chunk 0 (the lead, before any heading) is deliberately dropped here —
  /// callers already have that via the REST summary's `extract`.
  Map<String, String> _parseSections(String fullText) {
    final chunks = fullText.split(RegExp(r'\n{2,}'));
    final sections = <String, String>{};
    for (var i = 1; i < chunks.length; i++) {
      final newlineIndex = chunks[i].indexOf('\n');
      if (newlineIndex == -1) continue;
      final heading = chunks[i].substring(0, newlineIndex).trim().toLowerCase();
      final body = chunks[i].substring(newlineIndex + 1).trim();
      if (heading.isEmpty || body.isEmpty) continue;
      sections[heading] = body;
    }
    return sections;
  }

  String? _sectionBodyMatching(Map<String, String> sections, List<String> keywords) {
    for (final entry in sections.entries) {
      if (keywords.any((k) => entry.key.contains(k))) return entry.value;
    }
    return null;
  }

  // A bare `[^.!?]+[.!?]+` would treat the decimal point in "3.5–7
  // centimetres" as a sentence end, truncating mid-measurement — the
  // `\.(?=\d)` alternative lets a period followed by a digit be consumed as
  // part of the sentence instead of ending it there.
  static final _sentencePattern = RegExp(r'(?:[^.!?]|\.(?=\d))+[.!?]+');

  List<String> _sentences(String text) => _sentencePattern
      .allMatches(text)
      .map((m) => m.group(0)!.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  String? _firstMatchingSentence(String text, bool Function(String) predicate,
      {int maxLen = 240}) {
    for (final sentence in _sentences(text)) {
      if (!predicate(sentence)) continue;
      return sentence.length > maxLen
          ? '${sentence.substring(0, maxLen).trimRight()}…'
          : sentence;
    }
    return null;
  }

  static final _distributionKeyword = RegExp(
    r'\b(?:native to|found in|endemic to|distributed (?:across|throughout|in)|occurs in|inhabits)\b',
    caseSensitive: false,
  );

  /// A dedicated "Distribution"/"Range"/"Habitat" section is almost always
  /// itself just about location, so its first sentence alone is usually a
  /// clean, standalone answer (e.g. "Lucanus cervus is widespread across
  /// Europe, though it is absent from Ireland."). Falls back to scanning the
  /// lead paragraph for a habitat-ish sentence when there's no such section.
  String? _findRegion(Map<String, String> sections, String? leadExtract) {
    final sectionBody =
        _sectionBodyMatching(sections, ['distribution', 'range', 'habitat']);
    if (sectionBody != null) {
      final sentences = _sentences(sectionBody);
      if (sentences.isNotEmpty) {
        final first = sentences.first;
        return first.length > 240 ? '${first.substring(0, 240).trimRight()}…' : first;
      }
    }
    if (leadExtract == null) return null;
    return _firstMatchingSentence(
        leadExtract, (s) => _distributionKeyword.hasMatch(s));
  }

  static final _measurementPattern = RegExp(
    r'\d+(?:\.\d+)?\s*(?:[-–]|to)\s*\d+(?:\.\d+)?\s*(?:mm|cm|millimet(?:er|re)s?|centimet(?:er|re)s?|inches?|in\.)'
    r'|\d+(?:\.\d+)?\s*(?:mm|cm|millimet(?:er|re)s?|centimet(?:er|re)s?|inches?|in\.)',
    caseSensitive: false,
  );

  /// A "Description"/"Morphology" section is where body-size measurements
  /// live (e.g. "Males grow up to 7.5 centimetres (3.0 in) in length, and
  /// females grow between 3 and 5 centimetres..."); falls back to scanning
  /// the whole article when there's no such section.
  String? _findLength(Map<String, String> sections, String? fullText) {
    final body = _sectionBodyMatching(
            sections, ['description', 'morphology', 'appearance', 'identification']) ??
        fullText;
    if (body == null) return null;
    return _firstMatchingSentence(body, (s) => _measurementPattern.hasMatch(s));
  }

  static final _degreePattern = RegExp(r'-?\d+(?:\.\d+)?\s*°\s*[CF]');

  /// Temperature/climate mentions can turn up almost anywhere (Ecology,
  /// Habitat, Distribution, Biology, ...), so this scans the whole article
  /// rather than one section — prefers a sentence that says "temperature"
  /// outright, falling back to any sentence with a plain °C/°F reading.
  String? _findTemperature(String? fullText) {
    if (fullText == null) return null;
    return _firstMatchingSentence(fullText,
            (s) => s.toLowerCase().contains('temperature') && _degreePattern.hasMatch(s)) ??
        _firstMatchingSentence(fullText, (s) => _degreePattern.hasMatch(s));
  }

  /// Downloads [imageUrl] and copies it into the app's documents directory,
  /// mirroring [SpeciesLookupService]'s "download once, store a local path"
  /// convention already used for specimen photos — returns the local path,
  /// or null if the download fails.
  Future<String?> downloadPhoto(String imageUrl) async {
    try {
      final response =
          await http.get(Uri.parse(imageUrl)).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(docsDir.path, 'species_photos'));
      if (!await photosDir.exists()) await photosDir.create(recursive: true);
      var ext = p.extension(Uri.parse(imageUrl).path);
      if (ext.isEmpty || ext.length > 5) ext = '.jpg';
      final newPath = p.join(photosDir.path, '${const Uuid().v4()}$ext');
      await File(newPath).writeAsBytes(response.bodyBytes);
      return newPath;
    } catch (_) {
      return null;
    }
  }

  /// Fetches wiki data for [species] and saves it straight into its
  /// [SpeciesInfo] row via [AppDatabase.upsertSpeciesInfo] — the single
  /// entry point used both right after a species is unlocked (fire-and-
  /// forget, no popup/UI depends on this finishing) and from the species
  /// page's manual "Refresh from wiki" button. Does nothing and returns
  /// false if the wiki lookup comes back empty (offline, no match) rather
  /// than clearing out any info already saved; returns true if it found and
  /// saved something.
  Future<bool> fillFromWiki(AppDatabase db, String species) async {
    final result = await fetchWikiSummary(species);
    if (result == null) return false;
    final photoPath = result.photoUrl == null
        ? null
        : await downloadPhoto(result.photoUrl!);
    // Only ever overwrite a field when this fetch actually found something
    // for it — an empty/absent result on this particular fetch shouldn't
    // blank out a value from a manual edit or an earlier successful fetch.
    await db.upsertSpeciesInfo(
      species,
      description: result.description == null
          ? const Value.absent()
          : Value(result.description),
      region:
          result.region == null ? const Value.absent() : Value(result.region),
      lengthRangeText: result.lengthRangeText == null
          ? const Value.absent()
          : Value(result.lengthRangeText),
      temperatureRangeText: result.temperatureRangeText == null
          ? const Value.absent()
          : Value(result.temperatureRangeText),
      photoPath: photoPath == null ? const Value.absent() : Value(photoPath),
      sourceUrl: result.sourceUrl == null
          ? const Value.absent()
          : Value(result.sourceUrl),
      gbifUrl:
          result.gbifUrl == null ? const Value.absent() : Value(result.gbifUrl),
      wikiFetchedAt: Value(DateTime.now()),
    );
    return true;
  }
}
