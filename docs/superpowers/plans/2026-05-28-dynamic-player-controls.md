# Dynamic Player Controls Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Polish the shuffle and repeat buttons in the player screen with dynamic icons, colors, and smooth transitions.

**Architecture:** Handle local UI state (animations) within the `PlayerScreen` widget while remaining synced with the `PlaybackNotifier` state. Use `AnimatedSwitcher` for icon transitions and `AnimatedOpacity` for indicators.

**Tech Stack:** Flutter, Riverpod, Material Icons.

---

### Task 1: Refactor Shuffle Button

**Files:**
- Modify: `lib/screens/player_screen.dart`

- [ ] **Step 1: Update Shuffle Button implementation**
Replace the static shuffle button with an animated version that includes a scale effect and a dot indicator.

```dart
// Inside _buildControls in lib/screens/player_screen.dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
        child: Icon(
          playback.isShuffled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
          key: ValueKey(playback.isShuffled),
          color: playback.isShuffled ? Theme.of(context).colorScheme.primary : Colors.white38,
          size: res.sp(26),
        ),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        ref.read(playbackProvider.notifier).toggleShuffle();
      },
    ),
    AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: playback.isShuffled ? 1.0 : 0.0,
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    ),
  ],
)
```

- [ ] **Step 2: Verify Shuffle transition**
Check that the icon scales when toggled and the dot indicator fades in/out.

- [ ] **Step 3: Commit**
```bash
git add lib/screens/player_screen.dart
git commit -m "ui: add dynamic shuffle button with animation and indicator"
```

---

### Task 2: Refactor Repeat Button

**Files:**
- Modify: `lib/screens/player_screen.dart`

- [ ] **Step 1: Update Repeat Button implementation**
Use `AnimatedSwitcher` to cross-fade and scale between the three repeat states (None, All, One).

```dart
// Inside _buildControls in lib/screens/player_screen.dart
IconButton(
  icon: AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      );
    },
    child: Icon(
      playback.repeatMode == RepeatMode.one
          ? Icons.repeat_one_on_rounded
          : playback.repeatMode == RepeatMode.all
              ? Icons.repeat_on_rounded
              : Icons.repeat_rounded,
      key: ValueKey(playback.repeatMode),
      color: playback.repeatMode != RepeatMode.none
          ? Theme.of(context).colorScheme.primary
          : Colors.white38,
      size: res.sp(26),
    ),
  ),
  onPressed: () {
    HapticFeedback.lightImpact();
    ref.read(playbackProvider.notifier).cycleRepeatMode();
  },
)
```

- [ ] **Step 2: Verify Repeat cycle animation**
Cycle through None -> All -> One and ensure the transitions are smooth and the icons match the state.

- [ ] **Step 3: Commit**
```bash
git add lib/screens/player_screen.dart
git commit -m "ui: add dynamic repeat button with cross-fade and scale transitions"
```

---

### Task 3: Final Polish and Spacing

**Files:**
- Modify: `lib/screens/player_screen.dart`

- [ ] **Step 1: Adjust control bar spacing and alignment**
Ensure the `Row` has proper padding and alignment to avoid visual jitter during animations.

- [ ] **Step 2: Verify overall feel**
Run the app, toggle all controls, and ensure everything feels responsive and high-quality.

- [ ] **Step 3: Commit**
```bash
git add lib/screens/player_screen.dart
git commit -m "ui: finalize player controls spacing and polish"
```
