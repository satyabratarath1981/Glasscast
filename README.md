# 🌤️ Glasscast - Beautiful Weather App

A modern iOS weather application built with SwiftUI, featuring glass morphism design, real-time weather data, and seamless authentication.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## ✨ Features

- 🔐 **Secure Authentication** - Email/password login powered by Supabase
- 🌍 **Real-time Weather** - Current conditions and 5-day forecast
- 🔍 **City Search** - Search and save locations worldwide
- 📱 **Glass Morphism UI** - Modern, beautiful interface design
- ⚙️ **Settings** - Celsius/Fahrenheit toggle, notifications
- 🔄 **Pull to Refresh** - Easy weather updates
- 💾 **Session Persistence** - Stay logged in
- 🌐 **Location Support** - Auto-detect current location

## 📱 Screenshots

### Authentication Flow
| Login Screen | Home Screen | Search Screen |
|-------------|------------|---------------|
| ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Search](screenshots/search.png) |

### Settings & Features
| Settings | 5-Day Forecast | Location Detection |
|----------|---------------|-------------------|
| ![Settings](screenshots/settings.png) | ![Forecast](screenshots/forecast.png) | ![Location](screenshots/location.png) |

## 🛠️ Tech Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Backend**: Supabase (Authentication)
- **Weather API**: OpenWeatherMap
- **Concurrency**: Swift Async/Await
- **State Management**: Combine + @Published
- **Persistence**: UserDefaults + Supabase Session Storage

## 📋 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- macOS 13.0+ (for development)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/glasscast.git
cd glasscast
```

### 2. Install Dependencies

The project uses Swift Package Manager. Dependencies will be automatically downloaded by Xcode:

- [Supabase Swift](https://github.com/supabase/supabase-swift) (2.0.0+)

### 3. Configure Environment Variables

#### Option A: Using Config.xcconfig (Recommended)

1. Create a file `Config.xcconfig` in the project root:

```bash
touch Config.xcconfig
```

2. Add your credentials to `Config.xcconfig`:

```xcconfig
// Config.xcconfig
SUPABASE_URL = https://<your-project-id>.supabase.co
SUPABASE_ANON_KEY = your-supabase-anon-key-here
WEATHER_API_KEY = your-openweathermap-api-key-here
```

3. Add `Config.xcconfig` to `.gitignore`:

```bash
echo "Config.xcconfig" >> .gitignore
```

4. Update `SupabaseService.swift`:

```swift
private init() {
    guard let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""),
          let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] else {
        fatalError("Missing Supabase configuration. Check Config.xcconfig")
    }
    
    self.client = SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: supabaseKey
    )
}
```

5. Update `WeatherService.swift`:

```swift
private let apiKey = ProcessInfo.processInfo.environment["WEATHER_API_KEY"] ?? ""
```

6. Add the config file to your Xcode project:
   - In Xcode: Project Settings → Info → Configurations
   - Set Debug and Release to use `Config.xcconfig`

#### Option B: Direct Configuration (Quick Start)

1. Open `Services/SupabaseService.swift`
2. Replace the placeholder values:

```swift
let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

3. Open `Services/WeatherService.swift`
4. Replace the API key:

```swift
private let apiKey = "YOUR_OPENWEATHERMAP_API_KEY"
```

⚠️ **Warning**: Never commit actual credentials to version control!

### 4. Set Up Supabase Backend

#### Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click **"New project"**
3. Fill in:
   - **Name**: Glasscast
   - **Database Password**: (create a strong password)
   - **Region**: (choose closest to you)
4. Click **"Create new project"** (wait 2-3 minutes)

#### Get API Credentials

1. In your project, go to **Settings** → **API**
2. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGci...` (long string)

#### Enable Email Authentication

1. Go to **Authentication** → **Providers**
2. Find **Email** provider and toggle it **ON**
3. For testing, scroll down and **disable "Confirm email"**
4. Click **"Save"**

#### Create Test User

1. Go to **Authentication** → **Users**
2. Click **"Add user"** → **"Create new user"**
3. Enter:
   - **Email**: `test@glasscast.com`
   - **Password**: `test123456` (at least 6 characters)
4. Click **"Create user"**

### 5. Set Up OpenWeatherMap API

#### Get Free API Key

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Click **"Sign Up"** (free tier is sufficient)
3. Verify your email
4. Go to [API Keys](https://home.openweathermap.org/api_keys)
5. Copy your default API key or create a new one

⏰ **Note**: New API keys take **10-15 minutes** to activate!

### 6. Build and Run

1. Open `Glasscast.xcodeproj` in Xcode
2. Select a simulator or device (iOS 17.0+)
3. Press **⌘R** to build and run
4. Wait for dependencies to download

## 🎯 Usage

### First Launch

1. App opens to login screen
2. Enter your test credentials
3. Tap **"Log In"**
4. After successful login, you'll see the home screen with weather data

### Testing the App

#### Test Authentication
```
Email: test@glasscast.com
Password: test123456
```

#### Test Features
- ✅ Pull down to refresh weather
- ✅ Tap search icon to search cities
- ✅ Tap settings icon to change units
- ✅ Force quit and relaunch (stays logged in)
- ✅ Log out from settings

## 📁 Project Structure

```
Glasscast/
├── GlasscastApp.swift          # App entry point
├── Views/
│   ├── Auth/
│   │   └── LoginView.swift     # Login screen
│   ├── Home/
│   │   └── HomeView.swift      # Main weather screen
│   ├── Search/
│   │   └── SearchView.swift    # City search
│   └── Settings/
│       └── SettingsView.swift  # Settings screen
├── ViewModels/
│   ├── AuthViewModel.swift     # Authentication logic
│   ├── WeatherViewModel.swift  # Weather data logic
│   ├── SearchViewModel.swift   # Search logic
│   └── SettingsViewModel.swift # Settings logic
├── Services/
│   ├── SupabaseService.swift   # Authentication API
│   └── WeatherService.swift    # Weather API
├── Models/
│   └── (Defined in Services)   # Data models
└── Config.xcconfig             # Environment variables (gitignored)
```

## 🏗️ Architecture

### MVVM Pattern

```
View (SwiftUI)
    ↓
ViewModel (@MainActor)
    ↓
Service (Actor/Class)
    ↓
API (Supabase/OpenWeatherMap)
```

### State Management

- **@StateObject**: ViewModel initialization
- **@Published**: Reactive state updates
- **Combine**: NotificationCenter observers
- **Actor**: Thread-safe API services
- **@MainActor**: UI updates on main thread

### Memory Management

- ✅ Proper `deinit` implementations
- ✅ Task cancellation on view dismiss
- ✅ Weak references in closures
- ✅ 5-minute weather cache
- ✅ No retain cycles

## 🔧 Configuration

### Location Permissions

Required in `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show local weather conditions</string>
```

### Notification Permissions (Optional)

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Get alerts for weather changes and severe conditions</string>
```

### Temperature Units

Users can toggle between Celsius and Fahrenheit in Settings.
Default: Celsius

### API Rate Limits

**OpenWeatherMap Free Tier:**
- 60 calls/minute
- 1,000 calls/day
- Perfect for this app!

**Supabase Free Tier:**
- 50,000 monthly active users
- 500 MB database
- 1 GB file storage

## 🐛 Troubleshooting

### "API key is invalid" Error

**Supabase:**
- ✅ Check you copied the **anon/public** key (not service_role)
- ✅ Verify URL format: `https://PROJECT_ID.supabase.co`
- ✅ No extra spaces in credentials

**OpenWeatherMap:**
- ✅ Wait 10-15 minutes after creating key
- ✅ Check key is correctly pasted
- ✅ Test in browser: `https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_KEY`

### Login Works But No Navigation

1. Delete the app from simulator
2. **Product** → **Clean Build Folder** (⌘⇧K)
3. Rebuild and run
4. Check console for logs

### App Goes Directly to Home

Session from previous login is persisted (this is normal behavior).

To test fresh login:
1. Go to Settings → Log Out
2. Force quit app
3. Relaunch → should show login

### Weather Not Loading

1. Check OpenWeatherMap API key is valid
2. Verify internet connection
3. Check console for error messages
4. Try different city in search

## 🧪 Testing

### Manual Testing Checklist

- [ ] Clean install shows login screen
- [ ] Invalid credentials show error
- [ ] Valid credentials navigate to home
- [ ] Session persists after app restart
- [ ] Weather data loads correctly
- [ ] Pull to refresh works
- [ ] City search works
- [ ] Settings save correctly
- [ ] Logout clears session
- [ ] Location permission flow works

### Console Debugging

Enable detailed logs by checking console output:
- 🔵 Blue: Info messages
- ✅ Green checkmark: Success
- ❌ Red X: Errors
- 📊 Chart: Data operations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- [Supabase](https://supabase.com) - Backend and Authentication
- [OpenWeatherMap](https://openweathermap.org) - Weather Data API
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Icons
- SwiftUI Community - Inspiration and support

## 🗺️ Roadmap

### Version 1.0 (Current)
- ✅ Email/password authentication
- ✅ Current weather display
- ✅ 5-day forecast
- ✅ City search
- ✅ Settings

### Version 1.1 (Planned)
- [ ] Hourly forecast
- [ ] Weather alerts
- [ ] Multiple saved locations
- [ ] Weather maps
- [ ] Widgets

### Version 2.0 (Future)
- [ ] Social login (Apple, Google)
- [ ] Push notifications
- [ ] Weather sharing
- [ ] Dark mode customization
- [ ] iPad support

## 📞 Support

For issues and questions:
1. Check [Troubleshooting](#-troubleshooting) section
2. Search [existing issues](https://github.com/yourusername/glasscast/issues)
3. Create a [new issue](https://github.com/yourusername/glasscast/issues/new)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📸 Screenshots Directory Structure

```
screenshots/
├── login.png           # Login screen
├── home.png           # Home weather screen
├── search.png         # City search screen
├── settings.png       # Settings screen
├── forecast.png       # 5-day forecast detail
└── location.png       # Location permission dialog
```

---

**Built with ❤️ using SwiftUI and Supabase**

*Last updated: January 2026*
