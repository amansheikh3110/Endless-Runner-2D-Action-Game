# 🏍️ Action Rider

An exciting 2D endless runner game built with Flutter, featuring a bike-riding character who must jump over obstacles to achieve the highest score possible!

![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Screenshots

### Start Screen
![Start Screen](screenshots/WhatsApp%20Image%202025-12-26%20at%208.06.32%20PM.jpeg)

### Gameplay
![Gameplay 1](screenshots/WhatsApp%20Image%202025-12-26%20at%208.06.32%20PM%20%281%29.jpeg)

![Gameplay 2](screenshots/WhatsApp%20Image%202025-12-26%20at%208.06.33%20PM.jpeg)

### Game Over Screen
![Game Over](screenshots/WhatsApp%20Image%202025-12-26%20at%208.06.34%20PM.jpeg)

## 🎮 Features

- **Endless Runner Gameplay**: Classic side-scrolling endless runner with smooth, responsive controls
- **Jump Mechanics**: Chrome Dino-style physics with symmetric jump arcs for precise obstacle clearing
- **Dynamic Difficulty**: Game speed gradually increases over time, similar to Chrome Dino
- **Score System**: Continuous scoring at 3 points per second with local high score tracking
- **High Score Notifications**: Pop-up notification when you achieve a new high score
- **Animated Character**: Smooth video-based character animation using bike riding footage
- **Custom Styling**: Beautiful gradient backgrounds and custom "GreatsRacing" font
- **Landscape Orientation**: Optimized for landscape gameplay
- **Precise Collision Detection**: Decoupled collision system with explicit hitboxes for fair gameplay

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code with Flutter extensions
- Android Emulator or physical device for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd seventh_flutter_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons** (if not already done)
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 How to Play

1. **Start the Game**: Tap the "TAP TO PLAY" button on the start screen
2. **Jump Over Obstacles**: Tap the jump button (right side of screen) to make your character jump
3. **Avoid Collisions**: Don't let your character touch any obstacles - you'll lose!
4. **Score Points**: Your score increases by 3 points every second
5. **Beat Your High Score**: Try to achieve a new high score and see the celebration pop-up
6. **Game Over**: When you hit an obstacle, the game ends and you can see your final score

### Controls

- **Jump Button**: Located on the right side of the screen - tap to jump over obstacles

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── assets/                   # Game assets (videos, images, fonts)
│   ├── bike_riding.mp4       # Character animation video
│   ├── obstacle_*.png        # Obstacle images
│   ├── app_icon.jpg          # App icon
│   └── greats-racing-font/    # Custom font files
├── models/
│   └── obstacle.dart         # Obstacle model and generation logic
├── screens/
│   ├── start_screen.dart     # Start screen with title and play button
│   └── game_screen.dart       # Main game screen with gameplay logic
├── utils/
│   └── score_manager.dart    # High score management using SharedPreferences
└── widgets/
    └── ring_obstacle.dart     # Ring obstacle widget (if used)

screenshots/                  # Game screenshots for README
```

## 🛠️ Technical Details

### Dependencies

- **video_player**: ^2.8.2 - For character animation video playback
- **shared_preferences**: ^2.2.2 - For local high score storage
- **flutter_launcher_icons**: ^0.13.1 - For generating app icons

### Key Features Implementation

- **Physics System**: Custom gravity-based jump mechanics with velocity calculations
- **Collision Detection**: Axis-aligned bounding box (AABB) collision with explicit hitboxes
- **Game Loop**: Timer-based game loop for smooth 60 FPS gameplay
- **State Management**: Flutter's built-in `setState` for reactive UI updates
- **Asset Management**: Properly configured assets in `pubspec.yaml`
- **Orientation Lock**: Landscape-only orientation for optimal gameplay

### Game Mechanics

- **Jump Physics**: 
  - Gravity: 0.85 (smooth descent)
  - Jump Force: 20.0 (responsive jump)
  - Max Jump Height: 300.0 pixels
  - Symmetric arc (equal time up and down)

- **Speed Scaling**:
  - Base Speed: 5.5
  - Speed Increment: 0.01 per frame
  - Max Speed: 12.0

- **Score System**:
  - Increment: 3 points per second
  - Continuous scoring during gameplay
  - High score saved locally

## 📦 Building for Release

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## 🎨 Customization

### Changing Game Speed

Edit `lib/screens/game_screen.dart`:
- `_baseSpeed`: Initial obstacle speed
- `_speedIncrement`: Speed increase per frame
- `_maxSpeed`: Maximum speed cap

### Adjusting Jump Height

Edit `lib/screens/game_screen.dart`:
- `_g`: Gravity value (lower = slower fall)
- `_jumpForce`: Jump strength (higher = higher jump)
- `_maxJumpHeight`: Maximum jump height limit

### Adding New Obstacles

1. Add obstacle image to `lib/assets/`
2. Update `pubspec.yaml` assets section
3. Add image path to `Obstacle.generateRandom()` in `lib/models/obstacle.dart`

## 📝 License

This project is licensed under the MIT License.

## 👨‍💻 Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📧 Contact

For questions or suggestions, please open an issue on the repository.

---

**Enjoy playing Action Rider! 🏍️💨**
