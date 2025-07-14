# 🎮 HabitQuest

**Transform your daily habits into epic RPG adventures!**

HabitQuest is a gamified habit tracker that turns your personal development journey into an engaging role-playing game. Build streaks, earn rewards, and level up your life one habit at a time.

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?style=flat&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Features

- 🎯 **Gamified Habit Tracking** - Turn daily routines into quests and achievements
- 📊 **Progress Analytics** - Beautiful charts and statistics to track your journey
- 🏆 **Reward System** - Earn points, badges, and unlock achievements
- 🎨 **Elegant UI Design** - iOS-like interface with smooth animations and glassmorphism effects
- 🔔 **Smart Notifications** - Gentle reminders to keep you on track
- 📱 **Offline-First** - Works seamlessly without internet connection
- 🌙 **Dark/Light Theme** - Adaptive theming for comfortable viewing
- 🎭 **Smooth Animations** - Delightful micro-interactions and transitions

## 📱 Screenshots

<div align="center">
  <img src="habit/Simulator Screenshot - iPhone 16 Plus - 2025-07-14 at 09.05.29.png" width="200" alt="Splash Screen" />
  <img src="habit/Simulator Screenshot - iPhone 16 Plus - 2025-07-14 at 09.24.57.png" width="200" alt="Home Dashboard" />
  <img src="habit/Simulator Screenshot - iPhone 16 Plus - 2025-07-14 at 09.25.05.png" width="200" alt="Habit List" />
  <img src="habit/Simulator Screenshot - iPhone 16 Plus - 2025-07-14 at 09.25.12.png" width="200" alt="Habit Details" />
</div>

<div align="center">
  <img src="habit/Simulator Screenshot - iPhone 16 Plus - 2025-07-14 at 09.25.22.png" width="200" alt="Progress Analytics" />
  <img src="habit/Simulator Screenshot - iPhone 16 Plus - 2025-07-14 at 09.25.30.png" width="200" alt="Profile & Achievements" />
  <img src="habit/Simulator Screenshot - iPhone 16 Plus - 2025-07-14 at 09.25.47.png" width="200" alt="Settings" />
</div>

*Experience the elegant, iOS-like interface with smooth animations and modern design patterns*

## 🛠️ Technology Stack

### Core Framework
- **Flutter 3.8.1+** - Cross-platform mobile development
- **Dart 3.8.1+** - Programming language

### State Management
- **Flutter Riverpod 2.6.1** - Reactive state management
- **Riverpod Generator** - Code generation for providers

### Local Storage
- **Hive 2.2.3** - Lightweight, fast NoSQL database
- **Hive Flutter** - Flutter integration for Hive

### UI & Animations
- **Cupertino Icons** - iOS-style icons
- **Lottie 3.3.1** - High-quality animations
- **Confetti 0.8.0** - Celebration animations
- **FL Chart 1.0.0** - Beautiful charts and graphs

### Notifications & Utilities
- **Flutter Local Notifications 19.3.0** - Local push notifications
- **Timezone 0.10.1** - Timezone handling
- **UUID 4.5.1** - Unique identifier generation
- **Intl 0.20.2** - Internationalization support

## 🏗️ Architecture

HabitQuest follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                 # Core functionality
│   ├── constants/        # App constants and configurations
│   ├── enums/           # Enumeration definitions
│   ├── navigation/      # App navigation logic
│   ├── services/        # Core services (notifications, storage)
│   ├── theme/           # App theming and design tokens
│   └── utils/           # Utility functions and helpers
├── data/                # Data layer
│   ├── datasources/     # Local and remote data sources
│   ├── models/          # Data models and DTOs
│   └── repositories/    # Repository implementations
├── domain/              # Business logic layer
│   ├── entities/        # Business entities
│   └── repositories/    # Repository interfaces
└── presentation/        # UI layer
    ├── providers/       # Riverpod providers
    ├── screens/         # App screens and pages
    └── widgets/         # Reusable UI components
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.8.1 or higher
- **Dart SDK** 3.8.1 or higher
- **iOS Simulator** or **Android Emulator** for testing
- **Xcode** (for iOS development)
- **Android Studio** (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/habitquest.git
   cd habitquest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (for Riverpod and Hive)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios

   # For Android
   flutter run -d android
   ```

### Development Setup

1. **Enable code generation watch mode** (optional, for development)
   ```bash
   flutter packages pub run build_runner watch
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Analyze code**
   ```bash
   flutter analyze
   ```

## 🎯 Key Features in Detail

### Gamification Elements
- **Quest System**: Transform habits into daily quests with XP rewards
- **Achievement Badges**: Unlock special badges for milestones and streaks
- **Level Progression**: Watch your character level up as you build consistency
- **Streak Tracking**: Maintain habit streaks with visual progress indicators

### Analytics & Insights
- **Progress Charts**: Beautiful visualizations of your habit journey
- **Streak Statistics**: Detailed breakdown of your consistency patterns
- **Performance Metrics**: Track completion rates and improvement trends
- **Calendar View**: Visual habit calendar with completion history

### User Experience
- **Intuitive Design**: Clean, modern interface inspired by iOS design principles
- **Smooth Animations**: Delightful micro-interactions and page transitions
- **Glassmorphism Effects**: Modern visual effects for premium feel
- **Responsive Layout**: Optimized for various screen sizes

## 🤝 Contributing

We welcome contributions to HabitQuest! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow the existing code style and architecture patterns
- Write tests for new features
- Update documentation as needed
- Use conventional commits for clear commit messages
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Riverpod** for excellent state management
- **Hive** for fast local storage
- **Design Inspiration** from iOS and modern mobile design patterns

## 📞 Support

If you have any questions or need help getting started:

- 📧 **Email**: support@habitquest.app
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/habitquest/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/habitquest/discussions)

---

<div align="center">
  <p><strong>Made with ❤️ and Flutter</strong></p>
  <p>Start your habit journey today with HabitQuest!</p>
</div>
