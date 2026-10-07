# Liquid Weather ☁️🧊

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

**Liquid Weather** is a modern, premium, and highly responsive weather application built with Flutter. It abandons the traditional flat Material Design in favor of a gorgeous **Liquid Glassmorphism** visual language—featuring floating animated blurred orbs, frosted glass containers, and seamless transitions.

## ✨ Features

- **Liquid Glass UI**: Beautiful frosted glass elements with a continuously animating backdrop of soft glowing orbs.
- **Responsive Design**: Carefully constrained layouts that look stunning on both mobile phones and wide screens (tablets/web).
- **Native Android Home Widget**: Includes a custom native Android widget (built with XML/Kotlin) that syncs real-time weather data directly to your home screen!
- **Temperature Trend Chart**: A custom-painted, glowing bezier curve graph that plots the precise temperature trend for the next 24 hours.
- **Multi-City Management**: Search globally, save your favorite cities with a swipe-to-delete gesture, and instantly switch weather contexts.
- **Dynamic Theming**: Seamlessly toggle between Light, Dark, or System themes.
- **Unit Conversions**: Switch between Celsius and Fahrenheit globally across the app in real-time.
- **State Management**: Built robustly utilizing **Riverpod** for reactive state and **SharedPreferences** for local persistence.
- **Open-Meteo API**: Utilizes the lightning-fast, open-source Open-Meteo API for accurate forecasting, sunrise/sunset, UV index, and more without needing API keys.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.13.0 or higher)
- Android Studio / Xcode (for emulation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/liquid_weather.git
   cd liquid_weather
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 🧩 Architecture & Packages
- **State Management**: [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod)
- **Local Storage**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **Location Services**: [`geolocator`](https://pub.dev/packages/geolocator)
- **Native Widget Sync**: [`home_widget`](https://pub.dev/packages/home_widget)
- **App Icons**: [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
- **API**: [Open-Meteo](https://open-meteo.com/)

## 📸 Adding the Native Widget (Android)
Once you install the app on an Android device or emulator:
1. Long-press on your Home Screen.
2. Select **Widgets**.
3. Scroll down to find **Liquid Weather**.
4. Drag and drop the beautifully styled gradient widget onto your screen!

---

*Designed and engineered with ❤️ using Flutter.*
# weather-apps
