# 📝 Tasks - Sanad Design System & UI Overhaul

> **Status:** 🟡 In Progress
> **Focus:** UI Consistency, Accessibility (Contrast), Standardized Components

## 1. Project Management & Setup
- [ ] Initialize `tasks.md` (Rule 2 Compliance)
- [ ] Sync with `Laufbahn.md` (Memory Log)

## 2. Color System & Accessibility (Web Content Accessibility Guidelines - WCAG)
- [ ] Audit `app_colors.dart` for low contrast ratios
- [ ] Fix `textHint` color (currently too light)
- [ ] Fix `textSecondary` color
- [ ] Ensure Primary Color has sufficient contrast on white/dark backgrounds
- [ ] Verify Error color contrast

## 3. Global Theme Data (`app_theme.dart`)
- [ ] Update `inputDecorationTheme` for standard form fields
- [ ] Implement `switchTheme` (Material 3 Toggle styles)
- [ ] Implement `dropdownMenuTheme` / `popupMenuTheme`
- [ ] Standardize `elevatedButtonTheme` for high visibility
- [ ] Ensure `cardTheme` has proper elevation and contrast

## 4. New Component: `SanadSwitch` (Toggle)
- [ ] Create `packages/ui/lib/src/widgets/inputs/sanad_toggle.dart`
- [ ] Implement Label + Switch layout
- [ ] Add visual feedback states (hover, focus)
- [ ] Ensure hit-test area is sufficient (Touch Target Size)

## 5. New Component: `SanadDropdown` (Droplist)
- [ ] Create `packages/ui/lib/src/widgets/inputs/sanad_dropdown.dart`
- [ ] Wrap `DropdownButtonFormField` for consistency
- [ ] Match styling with `TextInput` (Border, Padding, Color)
- [ ] Add Icon customization

## 6. Implementation: Admin App (Proof of Concept)
- [ ] Refactor `settings_screen.dart` to use `SanadSwitch`
- [ ] Refactor `settings_screen.dart` to use `SanadDropdown`
- [ ] Verify layout consistency

## 7. Documentation & Handoff
- [ ] Update `laufbahn.md` with new component usage
- [ ] Log future tasks (Refactor Patient/Staff/MFA apps)
