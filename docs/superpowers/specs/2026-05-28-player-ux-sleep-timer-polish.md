# Design Spec: Player UX Polish & Custom Sleep Timer

**Date:** 2026-05-28
**Status:** Approved
**Topic:** Re-positioning Favorite button and adding Custom Sleep Timer functionality.

## 1. Overview
Enhance the Player Screen layout by moving the Favorite button to a more standard location and providing users with the ability to set a custom sleep timer duration via a slider.

## 2. UI Changes

### A. AppBar Re-positioning
- **Move Favorite Button:** Remove the Favorite button from the bottom controls area (near song info) and move it to the `_buildAppBar` method.
- **Layout:** Position it to the right of the Sleep Timer indicator.
- **Visuals:** Use `Icons.favorite_rounded` (solid) when favorited and `Icons.favorite_outline_rounded` when not. Color: `secondary` theme color for active, `white38` for inactive.

### B. Sleep Timer BottomSheet (Enhanced)
- **Title:** "Sleep Timer" in bold.
- **Custom Slider:**
  - Add a `Slider` widget to select duration from 1 to 120 minutes.
  - Show the currently selected value dynamically (e.g., "45 mins").
  - Use theme primary color for the slider.
- **Quick Presets:** Keep buttons for 15, 30, 45, and 60 minutes for rapid setting.
- **Status Indicator:** If a timer is active, show the remaining time clearly and provide a "Stop Timer" button with an error/danger color scheme.

## 3. Logic & State
- **Riverpod Sync:** The slider value will update a local state (using `StateProvider` or a `Hook`) before being committed to `PlaybackNotifier.setSleepTimer`.
- **Haptic Feedback:** Trigger `HapticFeedback.lightImpact()` on Favorite toggle and when a timer is set.

## 4. Success Criteria
- [ ] Favorite button is successfully moved to the top-right AppBar.
- [ ] Sleep Timer BottomSheet includes a functional custom duration slider.
- [ ] All controls provide haptic feedback.
- [ ] UI remains responsive and follows the Melophile design system.
