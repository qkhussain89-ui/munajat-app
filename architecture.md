# Munājāt App Architecture

## Overview
Munājāt is an Islamic duʿā creation and management app with a unified design system supporting Light and Dark modes.

## Theme System

### Core Theme Files
- **`lib/theme/brand_theme.dart`** - Main unified theme system with complete Light/Dark palettes
  - `BrandTheme.light()` and `BrandTheme.dark()` provide complete ThemeData
  - `BrandTokens` extension provides additional brand colors not in standard ColorScheme
  - All colors defined as constants for single source of truth

- **`lib/theme/brand_tokens_extension.dart`** - Helper extension for easy access to BrandTokens
  - Provides `context.brandTokens` shorthand in any widget

### Legacy Theme Files (Maintained for compatibility)
- `lib/theme.dart` - Contains AppColorsLight, AppColorsDark, and legacy theme builders
- `lib/theme/app_theme.dart` - Original theme system (AppTheme)
- `lib/theme/app_tokens.dart` - Token definitions
- `lib/theme/tokens.dart` - AppTok constants
- `lib/theme/munajat_theme.dart` - Alternative theme extension

### Color Palette

#### Light Mode
- Background: #FFFDF9
- Surface (card): #FFFFFF
- Elevated (panels): #FCF6EE
- Accent (chips): #F7EADA
- Primary (copper): #C68A4A
- Secondary: #5C4A32
- Text Primary: #2C2114
- Text Secondary: #5C4A32
- Text Muted: #9C886C
- Border: #E3D6C6

#### Dark Mode
- Background: #0A0A0A
- Surface (card): #141414
- Elevated (panels): #191919
- Accent (chips): #161616
- Primary (copper): #C38C5A
- Secondary: #C9BBA9
- Text Primary: #F2E7D9
- Text Secondary: #C9BBA9
- Text Muted: #9E8974
- Border: #2A2320

### Theme Token Usage

#### Standard ColorScheme Properties
Use `Theme.of(context).colorScheme.*` for:
- `.background` - Page backgrounds
- `.surface` - Cards, sheets, dialogs
- `.primary` - Buttons, accents
- `.onPrimary` - Text on primary
- `.secondary` - Secondary elements
- `.onSurface` - Primary text
- `.error` - Error states
- `.outline` - Borders

#### Brand-Specific Properties
Use `context.brandTokens.*` for:
- `.surfaceElevated` - Elevated containers, overlays
- `.surfaceAccent` - Chip/badge backgrounds, accents
- `.border` - Borders, dividers
- `.textMuted` - Tertiary text
- `.copperHover` - Hover states
- `.copperGradient` - Gradient text/shapes
- `.controlTrackOn/Off` - Toggle/slider states

### Implementation Pattern

```dart
// Access colors in widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brandTokens = context.brandTokens;
    
    return Container(
      color: colorScheme.surface,
      child: Text(
        'Hello',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
    );
  }
}
```

## Implementation Status

### Completed Changes
✅ **Unified Theme System** - Created BrandTheme with comprehensive Light/Dark palettes
✅ **BrandTokens Extension** - Implemented for easy access to brand-specific colors
✅ **Main.dart Update** - Switched from AppTheme to BrandTheme
✅ **Intro Landing Screen** - Fixed duʿā preview card with theme-aware colors
✅ **Copper Chip Widget** - Updated to use ColorScheme instead of AppTok
✅ **Bottom Navigation** - Converted to use BrandTokens for gradient and colors
✅ **Flow Mode Overlay** - Updated all colors and controls to use theme system

### Known Light-Mode Fixes

#### Intro Landing Screen
- Fixed duʿā preview card to use `colorScheme.surface` and `brandTokens.border`
- Arabic text now uses `textPrimary` color (dynamic per theme)
- English text uses `textSecondary` color  
- Chips properly render with copper accents
- Card renders correctly in both Light and Dark modes

#### Component Updates
- **CopperChip**: Uses `colorScheme.primary` for copper, `colorScheme.surface` for background
- **BottomNavRefined**: Uses `brandTokens.copperGradient` for selected state, theme colors for borders
- **FlowModeOverlay**: All colors bound to theme (background, surface, text, primary)

### Remaining Components (Legacy Compatibility Maintained)
- AppTok constants still available for backward compatibility
- Old theme files (app_theme.dart, app_tokens.dart) maintained as fallback
- New components should use BrandTheme and BrandTokensExt

## Directory Structure

```
lib/
├── theme/
│   ├── brand_theme.dart          # Main unified theme system
│   ├── brand_tokens_extension.dart  # Easy access helper
│   ├── app_theme.dart            # Legacy system
│   ├── app_tokens.dart           # Token definitions
│   ├── tokens.dart               # AppTok constants
│   └── munajat_theme.dart        # Alternative extension
├── screens/
│   ├── intro_landing_screen.dart  # Onboarding
│   ├── home_screen.dart          # Main feed
│   ├── my_duas_refined_screen.dart # My Duʿās
│   ├── create_refined_screen.dart # Create duʿā
│   ├── viewer_refined_screen.dart # Duʿā detail/player
│   ├── profile_refined_screen.dart # User profile & settings
│   └── ...
├── components/
│   ├── bottom_nav_refined.dart   # Bottom navigation
│   ├── dua_card.dart             # Duʿā card widget
│   ├── top_nav_bar.dart          # Header component
│   └── ...
├── services/
│   ├── dua_service.dart          # Duʿā data management
│   ├── folder_service.dart       # Folder management
│   ├── user_service.dart         # User data
│   └── ...
└── main.dart                      # App entry, theme application
```

## Theme Mode Management

Theme mode is managed by `AppState`:
- **ThemeMode.light** - Always light
- **ThemeMode.dark** - Always dark
- **ThemeMode.system** - System default (recommended)

Switching is handled in the Settings screen, stored in SharedPreferences for persistence.

## Migration Notes

When updating UI components:
1. Replace hardcoded color constants with theme lookups
2. Use `colorScheme` for standard Material colors
3. Use `brandTokens` for brand-specific colors
4. Ensure both light and dark modes render correctly
5. Avoid platform-specific colors; use theme colors exclusively

## Verification Checklist

- [ ] Light mode renders all screens with proper light palette
- [ ] Dark mode maintains no-shadow style
- [ ] Copper accents consistent across all modes
- [ ] Text hierarchy visible in both modes
- [ ] Cards/sheets have proper borders and backgrounds
- [ ] Transitions between modes are smooth
- [ ] Gradient text opacity correct (1.0 light, 0.45 dark)
