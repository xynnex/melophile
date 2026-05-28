# Player UX Polish & Custom Sleep Timer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the favorite button to the top-right AppBar and add a custom duration slider to the sleep timer.

**Architecture:** Refactor `PlayerScreen` UI components. Use `StatefulBuilder` within the sleep timer bottom sheet to manage local slider state. Maintain global playback state via Riverpod.

**Tech Stack:** Flutter, Riverpod, HapticFeedback.

---

### Task 1: Re-position Favorite Button

**Files:**
- Modify: `lib/screens/player_screen.dart`

- [ ] **Step 1: Move Favorite button to AppBar**
Modify `_buildAppBar` to include the Favorite button to the right of the Sleep Timer button. Remove it from `_buildSongInfo`.

```dart
// lib/screens/player_screen.dart

// Update _buildAppBar
Widget _buildAppBar(BuildContext context, Responsive res, PlaybackState playback, WidgetRef ref) {
  final isFav = ref.watch(favoritesProvider).any((s) => s.id == playback.currentSong?.id);
  
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: res.wp(2), vertical: res.hp(1)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          iconSize: res.sp(32),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'NOW PLAYING',
          style: TextStyle(
            color: Colors.white60,
            fontSize: res.sp(10),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSleepTimerButton(context, res, playback, ref),
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isFav ? Theme.of(context).colorScheme.primary : Colors.white38,
              ),
              iconSize: res.sp(24),
              onPressed: () {
                HapticFeedback.lightImpact();
                if (playback.currentSong != null) {
                  ref.read(favoritesProvider.notifier).toggle(playback.currentSong!);
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}

// Update _buildSongInfo to remove old button
Widget _buildSongInfo(BuildContext context, Responsive res, Song song) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: res.wp(10)),
    child: Column(
      children: [
        Text(song.title, ...),
        SizedBox(height: res.hp(1)),
        Text(song.artist, ...),
      ],
    ),
  );
}
```

- [ ] **Step 2: Verify Favorite button position and function**
Check that the Favorite button is now at the top-right and still toggles correctly with haptic feedback.

- [ ] **Step 3: Commit**
```bash
git add lib/screens/player_screen.dart
git commit -m "ui: move favorite button to top-right appbar"
```

---

### Task 2: Enhance Sleep Timer Dialog with Custom Slider

**Files:**
- Modify: `lib/screens/player_screen.dart`

- [ ] **Step 1: Refactor _showSleepTimerDialog**
Use `StatefulBuilder` and add a `Slider` for custom minute selection.

```dart
// lib/screens/player_screen.dart

void _showSleepTimerDialog(BuildContext context, PlaybackState playback, WidgetRef ref, Responsive res) {
  double customMinutes = 30.0;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: EdgeInsets.all(res.wp(6)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sleep Timer', style: ...),
            if (playback.isSleepTimerActive) ...[
              // ... existing "Remaining" and "Stop Timer" logic
            ] else ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Custom Duration', style: TextStyle(opacity: 0.7)),
                  Text('${customMinutes.toInt()} mins', 
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: customMinutes,
                min: 1,
                max: 120,
                onChanged: (v) => setModalState(() => customMinutes = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(playbackProvider.notifier).setSleepTimer(Duration(minutes: customMinutes.toInt()));
                  Navigator.pop(context);
                },
                child: const Text('Set Timer'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [15, 30, 45, 60].map((mins) => ActionChip(
                  label: Text('$mins m'),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(playbackProvider.notifier).setSleepTimer(Duration(minutes: mins));
                    Navigator.pop(context);
                  },
                )).toList(),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 2: Verify Sleep Timer Slider**
Ensure the slider updates the displayed minutes and setting the timer works correctly.

- [ ] **Step 3: Commit**
```bash
git add lib/screens/player_screen.dart
git commit -m "ui: add custom duration slider to sleep timer dialog"
```

---

### Task 3: Final UX Polishing

**Files:**
- Modify: `lib/screens/player_screen.dart`

- [ ] **Step 1: Clean up and polish UI**
Adjust padding, colors, and ensure haptic feedback is applied to all interactive elements.

- [ ] **Step 2: Final Verification**
Run `flutter analyze` and manually verify all changes.

- [ ] **Step 3: Commit**
```bash
git add lib/screens/player_screen.dart
git commit -m "ui: final polish for player UX and sleep timer"
```
