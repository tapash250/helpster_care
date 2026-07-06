# Design System

> Reference: `AGENTS.md` §32–§35, §114–§120, §131, §138–§141.

Helpster Care uses **Material 3 exclusively**. Mixing Material 2, random UI
libraries, inconsistent styling, or hardcoded colors is forbidden.

## Design Language

Communicate **Trust, Professionalism, Healthcare, Clarity, Calmness**.
Characteristics: rounded corners, large cards, comfortable spacing, soft
shadows, minimal glass effects, high readability. Avoid decorative effects that
reduce usability.

## Theme Architecture (§117)

```
lib/app/theme/
├── app_theme.dart
├── light_theme.dart
├── dark_theme.dart
├── color_scheme.dart
├── typography.dart
├── spacing.dart
├── radius.dart
├── animations.dart
└── theme_extensions.dart
```

Widgets consume theme values only. Never hardcode visual properties.

## Colors (§118)

Use **semantic** colors via `ColorScheme` / `ThemeExtension`
(`Primary`, `Secondary`, `Surface`, `Success`, `Warning`, `Error`, `Critical`,
`Info`).

```dart
// Good
Theme.of(context).colorScheme.error
// Bad
Colors.red
```

## Design Tokens (§33, §120)

Never hardcode padding, radius, typography, animation duration, elevation, or
spacing. Use centralized tokens:

```dart
AppSpacing.md      // not EdgeInsets.all(13)
AppRadius.lg
AppAnimation.medium
```

Spacing scale: `xs, sm, md, lg, xl, 2xl`.

## Typography (§119)

Hierarchy: `Display, Headline, Title, Body, Label`. No hardcoded font sizes;
use the Material type scale; maintain consistent line height; prefer
readability over density.

## Status Indicators (§131)

Statuses (`Draft, Pending, Approved, Rejected, Admitted, Under Treatment,
Discharged, Closed`) have a **centralized** appearance. No per-screen custom
colors.

## Responsive & Accessibility (§34, §35, §138)

Support Phone / Tablet / Desktop (future). Avoid fixed widths and absolute
positioning. Mandatory accessibility: screen readers, large text, high
contrast, ≥ 48dp touch targets, keyboard navigation, focus indicators.

## Animation (§139)

Communicate state with Fade / Scale / Slide / Hero. Duration 150–300 ms. Respect
reduced-motion settings. Avoid long or decorative motion.
