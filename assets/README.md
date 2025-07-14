# HabitQuest Assets

## Splash Screen Assets

### Logo Requirements
- **Format**: PNG with transparency
- **Dimensions**: 
  - 1x: 120x120px (baseline)
  - 2x: 240x240px (high DPI)
  - 3x: 360x360px (extra high DPI)
- **Style**: Clean, modern icon representing habit tracking/goals
- **Colors**: Should work on both light and dark backgrounds

### Background Images (Optional)
- **Format**: PNG or JPG
- **Dimensions**: 
  - 1x: 375x812px (iPhone standard)
  - 2x: 750x1624px (iPhone Retina)
  - 3x: 1125x2436px (iPhone Pro)
- **Style**: Subtle, abstract patterns or gradients
- **Theme**: Productivity, growth, achievement

### Current Implementation
For now, we'll use:
- **Logo**: Text-based logo with app icon
- **Background**: Programmatic gradients using app theme colors
- **Effects**: Glassmorphism overlays for modern appeal

### Asset Structure
```
assets/
├── images/
│   ├── logo/
│   │   ├── app_logo.png (1x)
│   │   ├── app_logo@2x.png (2x)
│   │   └── app_logo@3x.png (3x)
│   └── splash/
│       ├── background.png (optional)
│       ├── background@2x.png (optional)
│       └── background@3x.png (optional)
└── README.md
```

### Temporary Assets
Until custom assets are created, the splash screen will use:
- App name typography with elegant styling
- Programmatic gradients using theme colors
- Icon fonts for visual elements
- Glassmorphism effects for premium feel
