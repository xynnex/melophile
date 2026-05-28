# Design Spec: Dynamic Player Controls

**Date:** 2026-05-28
**Status:** Approved (Conceptual)
**Topic:** Polishing Shuffle and Repeat buttons with dynamic UI/UX.

## 1. Overview
The goal is to improve the user experience of the player controls by providing clear, dynamic, and visually appealing feedback for Shuffle and Repeat states.

## 2. Component Design

### A. Shuffle Button
- **States:**
  - `OFF`: `Icons.shuffle_rounded`, Color: `white38`.
  - `ON`: `Icons.shuffle_on_rounded`, Color: `Theme.primary`.
- **Dynamic Elements:**
  - `AnimatedContainer` for background glow (subtle primary color blur when ON).
  - `AnimatedOpacity` for a small indicator dot below the icon when ON.
  - Light haptic feedback on toggle.

### B. Repeat Button
- **Cycle:** None -> All -> One.
- **Icon Mapping:**
  - `None`: `Icons.repeat_rounded`, Color: `white38`.
  - `All`: `Icons.repeat_on_rounded`, Color: `Theme.primary`.
  - `One`: `Icons.repeat_one_on_rounded`, Color: `Theme.primary`.
- **Dynamic Elements:**
  - `AnimatedSwitcher` with `ScaleTransition` and `FadeTransition` for switching between the three icons.
  - Light haptic feedback on toggle.

## 3. Implementation Details
- **Architecture:** Keep logic in `PlaybackNotifier`, but handle local animations in `PlayerScreen` using `AnimatedSwitcher` and `AnimatedContainer`.
- **Widgets:**
  - Use `InkResponse` for clean splash effects.
  - Wrap controls in a specialized `_DynamicControl` widget to handle state-specific styling.

## 4. Success Criteria
- [ ] Shuffle button clearly indicates ON/OFF status via icon, color, and dot.
- [ ] Repeat button cycles through 3 states with smooth cross-fade/scale animations.
- [ ] No layout shifts during transitions.
- [ ] Performance remains smooth (60fps).
