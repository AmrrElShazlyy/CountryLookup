# CountryLookup

A SwiftUI iOS application that allows users to search, add, and manage information about countries using the REST Countries API.

---

## 📱 Features

### Core Features
-  **Real-time Country Search** - Search countries by name with debounced API calls
-  **Location-based Auto-add** - Automatically adds user's current country on first install
-  **Persistent Storage** - Countries are cached using SwiftData for offline access
-  **Network Monitoring** - Real-time network connectivity detection
-  **Country Information** - Display country name, capital, and currencies
-  **Max Limit Validation** - Maximum 5 countries to be added with user-friendly alerts
-  **Swipe to Delete** - Easy removal of countries from the list
-  **Duplicate Prevention** - Cannot add the same country twice

### Technical Features
-  **MVVM Architecture** - Clean separation of concerns
-  **Protocol-based Design** - Dependency injection for testability
-  **Unit Tests** - Comprehensive test coverage
-  **Combine Framework** - Reactive programming for data flow
-  **SwiftData** - Modern data persistence
-  **Mock Objects** - Full testing infrastructure

---

## 🛠️ Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming
- **SwiftData** - Data persistence
- **CoreLocation** - GPS and location services
- **Network Framework** - Network connectivity monitoring
- **XCTest** - Unit testing framework

---

## 📋 Requirements

- iOS 17.0+

---

## 🚀 Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/CountryLookup.git
cd CountryLookup
```

2. Open the project in Xcode:

3. Build and run:
   - Select **iPhone 16 Pro Max** as the simulator (recommended)

### API Configuration

The app uses the [REST Countries API](https://restcountries.com/) which requires no API key.

---

### Important Note
⚠️ **The UI is optimized for iPhone 16 Pro Max**

- Best experience on iPhone 16 Pro Max simulator
- May not be 100% correct on other devices
- Layout not fully tested on smaller iPhones as it is a demo project.

---

## 👤 Author

**Amr El Shazly**
