# Forex Watchlist - Swift/SwiftUI

A native iOS forex watchlist app built with SwiftUI, SwiftData, and the modern `@Observable` pattern. This app provides real-time forex exchange rates with a clean, simple interface focused on core functionality.

## Features

- **Real-time Forex Data**: Live streaming of currency exchange rates with updates every 5 seconds
- **Customizable Watchlist**: Add/remove currency pairs with persistent storage using SwiftData
- **Interactive List Management**: 
  - Drag & drop to reorder pairs
  - Swipe to delete pairs
  - Pull to refresh for manual updates
- **Detailed Pair View**: Comprehensive forex data including bid/ask spread and technical details
- **Connection Status**: Visual indicators showing real-time connection status with relative timestamps
- **Modern Architecture**: Built with MVVM pattern using `@Observable` for clean separation of concerns
- **Comprehensive Testing**: Full unit test suite with mocking, async testing, and SwiftData validation

## Supported Currency Pairs

- USD/JPY (US Dollar / Japanese Yen)
- EUR/USD (Euro / US Dollar) 
- GBP/USD (British Pound / US Dollar)
- AUD/USD (Australian Dollar / US Dollar)
- USD/CAD (US Dollar / Canadian Dollar)
- USD/CHF (US Dollar / Swiss Franc)
- USD/CNY (US Dollar / Chinese Yuan)
- EUR/JPY (Euro / Japanese Yen)
- GBP/JPY (British Pound / Japanese Yen)

## Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent storage for watchlist configuration  
- **@Observable**: Modern observation pattern for reactive UI updates
- **MVVM Architecture**: Clean separation of concerns with ViewModels
- **Real-time API**: Direct integration with forex service API

## Prerequisites

Before running the application, you need to have the forex API service running:

### API Setup

1. **Pull the Docker image:**
   ```bash
   docker pull paidyinc/one-frame:latest
   ```

2. **Run the service:**
   ```bash
   docker run -p 8080:8080 paidyinc/one-frame
   ```

   The API service will be available at `http://localhost:8080`.

   The token is mentioned on image docker hub page
 


## Project Structure

```
forex-swift/
├── Models/
│   ├── ForexTypes.swift          # Currency types and data structures
│   └── WatchlistItem.swift       # SwiftData model for watchlist items
├── ViewModels/
│   └── WatchlistViewModel.swift  # Business logic and API management
├── Views/
│   ├── ContentView.swift         # Main watchlist interface
│   ├── Sheets/
│   │   ├── AddPairsView.swift    # Add currency pairs modal
│   │   └── PairDetailsView.swift # Detailed pair information
│   └── Subviews/
│       ├── ConnectionStatusBar.swift    # Connection status indicator
│       ├── EmptyWatchlistView.swift     # Empty state view
│       └── WatchlistItemRow.swift       # Individual watchlist item
├── Services/
│   └── ForexService.swift        # API communication layer
├── forex_swiftApp.swift          # App entry point with SwiftData setup
└── forex-swiftTests/             # Unit tests
    ├── ForexTypesTests.swift         # Currency types and data structure tests
    ├── WatchlistItemTests.swift      # SwiftData model tests
    ├── ForexServiceErrorTests.swift  # Error handling and service tests
    ├── WatchlistViewModelTests.swift # Business logic and ViewModel tests
    ├── MockForexService.swift        # Test doubles and mocking utilities
    └── forex_swiftTests.swift        # Basic infrastructure tests
```

## Architecture Highlights

### MVVM Pattern
- **Models**: SwiftData models for persistent storage
- **ViewModels**: `@Observable` classes managing business logic and API calls
- **Views**: SwiftUI views with reactive UI updates

### Data Flow
1. **SwiftData**: Persistent storage for user's watchlist configuration
2. **ViewModel**: Manages API calls, real-time updates, and business logic  
3. **API Service**: Direct communication with localhost:8080 forex API
4. **Real-time Updates**: Timer-based polling every 5 seconds for fresh data

### Error Handling
- **Typed Errors**: Custom error types with specific handling strategies
- **Connection Management**: Visual feedback for API connectivity status
- **Graceful Degradation**: Fallback behaviors for network issues

## Getting Started

1. **Clone the repository**
2. **Start the Docker forex API service** (see API Setup above)
3. **Open the project in Xcode**
4. **Select your target device/simulator** 
5. **Build and run** the project

## Usage

1. **Add Currency Pairs**: Tap the `+` button to add currency pairs to your watchlist
2. **View Details**: Tap any currency pair to see detailed information including bid/ask spread
3. **Reorder**: Press and hold to drag pairs into your preferred order
4. **Delete**: Swipe left on any pair to remove it from your watchlist
5. **Refresh**: Pull down to manually refresh all rates
6. **Connection Status**: Monitor the connection indicator at the top for real-time status

## Development Notes

- The app connects directly to `localhost:8080` (no server-side routes needed)
- SwiftData replaces localStorage for persistent watchlist storage
- Modern `@Observable` pattern used instead of `ObservableObject`
- Real-time updates every 5 seconds with intelligent error handling
- Connection status shows relative timestamps ("just now", "2m ago")
- All currency data sourced from the one-frame Docker API service

## Unit Testing

The project includes comprehensive unit tests covering all major components and business logic.

### Test Coverage

- **ForexTypes Tests**: Currency enums, forex rate calculations, API response handling
- **WatchlistItem Tests**: SwiftData model validation, currency property extraction
- **ForexService Tests**: Error handling, API communication, service reliability
- **WatchlistViewModel Tests**: Business logic, data management, real-time updates
- **MockForexService**: Test doubles for reliable, isolated testing

### Running Tests

#### In Xcode (Recommended)
1. Open the project: `open forex-swift.xcodeproj`
2. Run all tests: `⌘ + U` (Command + U)
3. Run specific tests: Open Test Navigator (`⌘ + 6`) and click the diamond icon next to any test
4. View results in the Test Navigator panel

#### From Command Line
```bash
# Run all tests
xcodebuild test -project forex-swift.xcodeproj -scheme forex-swift -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test class
xcodebuild test -project forex-swift.xcodeproj -scheme forex-swift -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:forex-swiftTests/ForexTypesTests

# Run specific test method
xcodebuild test -project forex-swift.xcodeproj -scheme forex-swift -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:forex-swiftTests/ForexTypesTests/testSupportedCurrencyValues
```

### Test Structure

```
forex-swiftTests/
├── ForexTypesTests.swift         # Currency types and data structure tests
├── WatchlistItemTests.swift      # SwiftData model tests
├── ForexServiceErrorTests.swift  # Error handling and service tests
├── WatchlistViewModelTests.swift # Business logic and ViewModel tests
├── MockForexService.swift        # Test doubles and mocking utilities
└── forex_swiftTests.swift        # Basic infrastructure tests
```

### Test Features

- **Mocking**: `MockForexService` for testing without external dependencies
- **SwiftData Testing**: In-memory model container for database tests
- **Async Testing**: Proper handling of async/await patterns in ViewModels
- **Error Scenarios**: Comprehensive error condition testing
- **Concurrency**: Swift 6 concurrency-safe testing with `@MainActor`

### Test Frameworks

- **XCTest**: Traditional unit testing framework
- **Swift Testing**: Modern testing framework (iOS 26+)
- **SwiftData**: In-memory testing for model validation

## Requirements

- iOS 26.0 (Beta version)
- Xcode 26.0 (Beta version)
- Docker (for running the forex API service)

## License

MIT License
