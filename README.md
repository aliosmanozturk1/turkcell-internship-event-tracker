# Event Tracker - iOS Application

A comprehensive iOS event management application built with SwiftUI and Firebase, featuring event creation, discovery, and management capabilities with modern iOS 17+ APIs.

## 🚀 Features

### Core Functionality
- **Event Management**: Create, view, edit, and manage events with rich details
- **User Authentication**: Apple Sign-In, Google Sign-In, and email/password authentication
- **Event Discovery**: Browse, search, and filter events by categories, location, date, and price
- **Location Integration**: MapKit integration for event venues with coordinate support
- **Image Management**: Multiple image upload and display with zoom capabilities
- **Real-time Updates**: Firebase Firestore real-time synchronization
- **Participant Tracking**: Manage event capacity and participant counts
- **Category System**: Organized event categories with group classification
- **Age Restrictions**: Configurable age limits for events
- **Pricing Support**: Free and paid events with currency formatting

### User Experience
- **Modern UI**: SwiftUI with iOS 17+ design patterns
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Dark Mode**: Dark mode support
- **Smooth Navigation**: NavigationPath-based routing system
- **Form Validation**: Input validation and error handling
- **Loading States**: Loading indicators and animations

## 📱 System Requirements

- **iOS Version**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **Device**: iPhone and iPad compatible

## 🏗️ Architecture

### Design Pattern
The application follows **MVVM (Model-View-ViewModel)** architecture with:

- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management
- **Models**: Data structures and entities
- **Services**: Firebase integration and API communication

### Core Components

#### Session Management
- **SessionManager** (`Core/Session/SessionManager.swift`): Global authentication state management
- Real-time Firebase Auth state monitoring
- User profile loading
- Automatic sign-out handling

#### Navigation System
- **Router** (`Navigation/Router.swift`): NavigationPath-based coordinator
- Programmatic navigation with `push()`, `pop()`, and `popToRoot()`
- Type-safe route definitions with **AppRoute** enum

#### Firebase Integration
- **FirebaseManager** (`Services/FirebaseManager.swift`): Singleton providing Firebase services
- **AuthService**: Authentication wrapper
- **EventService**: Firestore event operations
- **UserService**: User profile management
- **CategoryService**: Category and group management
- **ImageUploader**: Firebase Storage image handling

### Data Models

#### Primary Event Model
```swift
struct CreateEventModel: Identifiable, Codable {
    var title: String
    var description: String
    var categories: [String]
    var startDate: Date
    var endDate: Date
    var location: EventLocation
    var participants: EventParticipants
    var pricing: EventPricing
    var images: [EventImage]
    // ... additional properties
}
```

#### Supporting Models
- **EventLocation**: Venue details with coordinates
- **EventParticipants**: Capacity and attendance tracking
- **EventPricing**: Price information with currency
- **AgeRestriction**: Age limit configuration
- **EventOrganizer**: Organizer contact information

## 🛠️ Setup and Installation

### Prerequisites
1. **Xcode 15+** installed on macOS
2. **iOS 17+ Simulator** or physical device
3. **Firebase Project** with the following services:
   - Authentication
   - Firestore Database
   - Storage
   - (Optional) Realtime Database
4. **Apple Developer Account** (for device testing and Apple Sign-In)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone [repository-url]
   cd turkcell-internship-event-tracker
   ```

2. **Open Xcode Project**
   ```bash
   open "Event Tracker/Event Tracker.xcodeproj"
   ```

3. **Firebase Configuration**
   - Add your `GoogleService-Info.plist` to the project
   - Follow setup guide in `firebase-config/FIREBASE_SETUP.md`
   - Configure Firestore indexes and security rules

4. **Apple Sign-In Setup**
   - Enable "Sign In with Apple" capability in Xcode
   - Follow detailed guide in `docs/APPLE_SIGN_IN_GUIDE_EN.md`

5. **Build and Run**
   - Select iOS 17+ simulator or device
   - Press `Cmd+R` to build and run

## 📦 Dependencies

The project uses Swift Package Manager for dependency management:

### Firebase iOS SDK (v11.15.0)
- `FirebaseAuth`: User authentication
- `FirebaseFirestore`: NoSQL database
- `FirebaseStorage`: File and image storage
- `FirebaseDatabase`: Real-time database (optional)

### Google Sign-In (v9.0.0)
- Google authentication integration
- OAuth 2.0 implementation

### Lottie (v4.5.2)
- Animation framework for loading states
- JSON-based animations

## 🗂️ Project Structure

```
Event Tracker/
├── App/
│   ├── Event_TrackerApp.swift          # App entry point
│   └── RootView.swift                  # Root view controller
├── Core/
│   ├── Constants/                      # App constants
│   ├── Extensions/                     # Swift extensions
│   ├── Helpers/                        # Utility classes
│   ├── Session/                        # Session management
│   └── Utilities/                      # Common utilities
├── Features/
│   ├── Authentication/                 # Login/Register flows
│   ├── Events/                         # Event management
│   └── Profile/                        # User profile
├── Models/                             # Shared data models
├── Navigation/                         # Navigation logic
├── Resources/                          # Assets and animations
└── Services/                           # Firebase services
```

### Feature Organization
Each feature module contains:
- **Views**: SwiftUI view components
- **ViewModels**: Business logic and state
- **Models**: Feature-specific data structures
- **Components**: Reusable UI components

## 🔥 Firebase Configuration

### Firestore Collections
- **users**: User profiles and settings
- **events**: Event data with full CreateEventModel structure
- **categories**: Event categories organized in groups
- **event-images**: Image metadata and references

### Security Rules
- Events: Public read for active events, owner-only write
- Users: Private read/write access
- Categories: Public read access for authenticated users

### Indexes
Optimized composite indexes for:
- Event filtering by category, date, and status
- User event queries
- Pagination support
- Performance optimization

## 🎨 UI Components

### Custom Components
- **ModernTextField**: Enhanced text input with validation
- **ModernDatePicker**: Styled date selection
- **CategorySelector**: Multi-select category picker
- **PhotoThumbnail**: Image display with tap-to-zoom
- **ZoomableImageView**: Full-screen image viewer
- **LocationPickerView**: MapKit integration for venue selection

### Styling
- **ScaleButtonStyle**: Interactive button animations
- **CategoryCardButtonStyle**: Category selection styling
- Custom color schemes with hex color support

## 🔐 Authentication Flow

1. **Initial State**: App checks Firebase Auth state
2. **Authentication**: Users can sign in via:
   - Apple Sign-In
   - Google Sign-In
   - Email/Password
3. **Profile Completion**: First-time users complete profile
4. **Session Management**: Automatic state synchronization
5. **Sign-out**: Secure session termination

## 📍 Location Features

### MapKit Integration
- Interactive map for venue selection
- Coordinate storage and retrieval
- Location permissions handling

### EventLocation Structure
```swift
struct EventLocation {
    var name: String
    var address1: String
    var address2: String
    var city: String
    var district: String
    var latitude: String
    var longitude: String
}
```

## 🖼️ Image Management

### Upload Process
1. Image selection from photo library
2. Automatic resizing for optimization
3. Firebase Storage upload
4. Metadata storage in Firestore
5. Real-time URL generation

### Display Features
- Thumbnail generation
- Full-screen zoom view
- Multiple image support per event
- Loading state indicators

## 🔍 Event Discovery

### Filtering Options
- **Categories**: Multi-select category filtering
- **Date Range**: Start and end date selection
- **Location**: City and district filtering
- **Price Range**: Free to paid event filtering
- **Participants**: Available spots filtering
- **Age Restrictions**: Age-appropriate content

### Search Capabilities
- Text-based search across event titles and descriptions
- Real-time search results

## 🚀 Build and Deployment

### Development Build
1. Open project in Xcode
2. Select development team
3. Choose target device/simulator
4. Build with `Cmd+B`
5. Run with `Cmd+R`

## 🐛 Troubleshooting

### Common Issues

#### Firebase Configuration
- **Issue**: App crashes on launch
- **Solution**: Verify `GoogleService-Info.plist` is properly added to project

#### Apple Sign-In
- **Issue**: Sign-in button not working
- **Solution**: Check "Sign In with Apple" capability is enabled

#### Build Errors
- **Issue**: Swift Package Manager dependencies fail
- **Solution**: Clean build folder (`Cmd+Shift+K`) and rebuild

#### Firestore Index Errors
- **Issue**: Query requires index
- **Solution**: Follow the auto-generated index creation link in error message

### Debug Logging
The app includes comprehensive logging via the `Logger` utility:
```swift
Logger.info("Event created successfully", category: .events)
Logger.error("Authentication failed: \(error)", category: .authentication)
```

## 📈 Performance Optimization

### Implemented Optimizations
- **Image Compression**: Automatic resize before upload
- **Lazy Loading**: Efficient list rendering
- **Index Optimization**: Firestore composite indexes

## 🔮 Future Enhancements

### Planned Features
- [ ] Push notifications for event updates
- [ ] In-app messaging between organizers and participants
- [ ] Event recommendations based on user preferences
- [ ] QR code generation for events
- [ ] Offline mode improvements
- [ ] Analytics dashboard for event organizers

### Technical Improvements
- [ ] Unit and integration tests
- [ ] UI automation tests
- [ ] Performance monitoring
- [ ] Crash reporting integration