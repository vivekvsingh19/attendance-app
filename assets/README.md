# Assets Folder

This folder contains all the static assets for the ClassAttendence Flutter application.

## Structure

```
assets/
├── images/          # App images, illustrations, backgrounds
├── icons/           # Custom icons and icon images
├── fonts/           # Custom font files
└── README.md        # This file
```

## Usage

### Images
Place all image files (PNG, JPG, SVG) in the `images/` folder.
Access them in your code using:
```dart
Image.asset('assets/images/your_image.png')
```

### Icons
Place custom icon files in the `icons/` folder.
Access them in your code using:
```dart
Image.asset('assets/icons/your_icon.png')
```

### Fonts
Place custom font files (TTF, OTF) in the `fonts/` folder.
Remember to also add font configuration to `pubspec.yaml`:
```yaml
fonts:
  - family: YourFontName
    fonts:
      - asset: assets/fonts/YourFontName-Regular.ttf
      - asset: assets/fonts/YourFontName-Bold.ttf
        weight: 700
```

## File Naming Convention

- Use lowercase letters
- Use underscores for spaces
- Use descriptive names
- Examples: `app_logo.png`, `profile_placeholder.jpg`, `settings_icon.svg`

## Image Optimization

- Use appropriate image formats (PNG for transparency, JPG for photos)
- Optimize images for mobile (keep file sizes reasonable)
- Consider providing different resolutions for different screen densities
