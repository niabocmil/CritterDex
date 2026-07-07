import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/enums.dart';
import 'specimen_avatar.dart';

/// Celebratory "achievement unlocked" popup shown once, right after a
/// specimen of a species never recorded before is saved. Fires purely on
/// local data (is this the first specimen of this species ever?) — entirely
/// independent of the wiki lookup, which fills in separately in the
/// background and may still be empty by the time this shows.
///
/// Deliberately does its own navigating: it only ever pops itself with a
/// bool (true = "View species" was tapped). The caller — still holding the
/// specimen form open underneath — decides what to do with that after
/// popping the form itself, so a "View species" tap doesn't land a
/// [SpeciesDetailScreen] push that the form's own subsequent pop then
/// immediately closes again (both share the same navigator).
class SpeciesUnlockedDialog extends StatefulWidget {
  const SpeciesUnlockedDialog({
    super.key,
    required this.species,
    this.iconType,
    this.beetleFamily,
    this.lifeStage,
  });

  final String species;
  final SpecimenIconType? iconType;
  final BeetleFamily? beetleFamily;
  final BeetleLifeStage? lifeStage;

  /// Returns true if "View species" was tapped, false for "Nice!"/dismiss.
  static Future<bool> show(
    BuildContext context, {
    required String species,
    SpecimenIconType? iconType,
    BeetleFamily? beetleFamily,
    BeetleLifeStage? lifeStage,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => SpeciesUnlockedDialog(
        species: species,
        iconType: iconType,
        beetleFamily: beetleFamily,
        lifeStage: lifeStage,
      ),
    );
    return result ?? false;
  }

  @override
  State<SpeciesUnlockedDialog> createState() => _SpeciesUnlockedDialogState();
}

class _SpeciesUnlockedDialogState extends State<SpeciesUnlockedDialog> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 24,
                      color: Colors.black38,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: scheme.primaryContainer,
                    child: widget.iconType == null
                        ? Icon(Icons.emoji_events,
                            size: 36, color: scheme.onPrimaryContainer)
                        : SpecimenAvatar(
                            iconType: widget.iconType!,
                            beetleFamily: widget.beetleFamily,
                            lifeStage: widget.lifeStage,
                            radius: 36,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Species unlocked!',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.species,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "First one of these you've added!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('View species'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Nice!'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 28,
            maxBlastForce: 24,
            minBlastForce: 10,
            gravity: 0.25,
            colors: const [
              Colors.amber,
              Colors.pinkAccent,
              Colors.lightBlueAccent,
              Colors.greenAccent,
              Colors.deepPurpleAccent,
            ],
          ),
        ),
      ],
    );
  }
}
