import 'dart:async';

import 'package:flutter/material.dart';

import '../services/species_lookup_service.dart';

/// Scientific-name search field for the specimen form's Species entry:
/// search-as-you-type suggestions from GBIF's open taxonomic database,
/// shown inline below the field like a normal searchbar. Selecting one just
/// fills the text field — nothing is force-selected, so an obscure species,
/// hobbyist/trade name, or color morph not in GBIF's database still saves
/// fine as plain custom text.
class SpeciesSearchField extends StatefulWidget {
  const SpeciesSearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<SpeciesSearchField> createState() => _SpeciesSearchFieldState();
}

class _SpeciesSearchFieldState extends State<SpeciesSearchField> {
  final _service = SpeciesLookupService();
  Timer? _debounce;
  List<SpeciesSuggestion> _suggestions = [];
  bool _loading = false;
  // Distinguishes "haven't searched this text yet" from "searched, nothing
  // matched" — only the latter shows the "no match" hint.
  bool _searchedCurrentText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final query = widget.controller.text.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _loading = false;
        _searchedCurrentText = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _searchedCurrentText = false;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _service.searchNames(query);
      if (!mounted) return;
      // The text may have changed while this request was in flight — drop
      // a stale response instead of showing suggestions for old input.
      if (widget.controller.text.trim() != query) return;
      setState(() {
        _suggestions = results;
        _loading = false;
        _searchedCurrentText = true;
      });
    });
  }

  void _select(SpeciesSuggestion suggestion) {
    widget.controller.value = TextEditingValue(
      text: suggestion.name,
      selection: TextSelection.collapsed(offset: suggestion.name.length),
    );
    setState(() {
      _suggestions = [];
      _searchedCurrentText = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.controller.text.trim();
    final showNoMatchHint = _searchedCurrentText &&
        !_loading &&
        _suggestions.isEmpty &&
        query.length >= 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: 'Species *',
            hintText: 'Scientific name, e.g. Lucanus cervus',
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
          ),
        ),
        if (showNoMatchHint)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'No match — will save as a custom species',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        if (_suggestions.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, i) {
                  final s = _suggestions[i];
                  return ListTile(
                    dense: true,
                    title: Text(s.name,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                    subtitle: s.subtitle == null ? null : Text(s.subtitle!),
                    onTap: () => _select(s),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
