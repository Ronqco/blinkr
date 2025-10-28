# Blinkr V2 - Social Network App

A proximity-based social networking app built with Flutter and Supabase, combining location-based discovery with interest-based feeds.

## Features

### Core Features
- **Proximity-based Discovery**: Find users nearby based on geolocation (with privacy protection)
- **58 Interest Categories**: Including general and NSFW categories with opt-in filtering
- **Reddit-style Feeds**: Thematic content feeds per interest category
- **E2E Encrypted Chat**: Secure messaging with RSA/AES encryption
- **Gamification System**: XP and levels per interest category with achievements
- **Flexible Content Moderation**: Allows NSFW content with warnings, blocks only illegal content

### Monetization
- **Freemium Model**: 50 messages per day for free users
- **Ad-supported Unlocks**: Watch rewarded ads to unlock +10 messages
- **Premium Subscription**: $2.99/month for unlimited messaging and ad-free experience

### Security & Privacy
- End-to-end encryption for all messages
- Approximate location only (±500m noise added)
- Secure key storage with Flutter Secure Storage
- Row Level Security (RLS) policies in Supabase
- GDPR compliant data handling

## Tech Stack

### Frontend
- **Flutter/Dart**: Cross-platform mobile framework
- **BLoC Pattern**: State management with flutter_bloc
- **Clean Architecture**: Separation of concerns with domain/data/presentation layers

### Backend
- **Supabase**: PostgreSQL database with real-time subscriptions
- **PostGIS**: Geospatial queries for proximity features
- **Supabase Auth**: User authentication and authorization
- **Supabase Storage**: Media file storage

### Key Dependencies
\`\`\`yaml
dependencies:
  flutter_bloc: ^8.1.3
  supabase_flutter: ^2.0.0
  get_it: ^7.6.4
  dartz: ^0.10.1
  equatable: ^2.0.5
  geolocator: ^10.1.0
  flutter_secure_storage: ^9.0.0
  pointycastle: ^3.7.3
  encrypt: ^5.0.3
  google_mobile_ads: ^4.0.0
  in_app_purchase: ^3.1.11
  go_router: ^12.1.1
  hive_flutter: ^1.1.0
\`\`\`

## Project Structure

\`\`\`
lib/
├── core/
│   ├── config/           # App configuration and theme
│   ├── constants/        # Interest categories and constants
│   ├── database/         # Supabase client setup
│   ├── encryption/       # E2E encryption service
│   ├── error/           # Error handling
│   ├── location/        # Geolocation service
│   ├── router/          # App navigation
│   ├── services/        # Core services (ads, subscriptions)
│   └── storage/         # Secure storage service
├── features/
│   ├── auth/            # Authentication feature
│   ├── chat/            # E2E encrypted chat
│   ├── discovery/       # Proximity-based user discovery
│   ├── feed/            # Interest-based content feeds
│   ├── gamification/    # XP, levels, achievements
│   ├── home/            # Home navigation
│   ├── premium/         # Premium subscription
│   └── profile/         # User profiles
└── main.dart
\`\`\`

## Database Schema

### Main Tables
- `users`: User profiles with bio, avatar, location
- `user_interests`: Many-to-many relationship for user interests
- `interest_categories`: 58 predefined categories
- `posts`: Feed content with NSFW flags
- `comments`: Post comments
- `post_likes`: Like tracking
- `conversations`: Chat conversations
- `messages`: E2E encrypted messages
- `user_xp`: Gamification XP per category
- `achievements`: Unlockable achievements
- `user_subscriptions`: Premium subscription tracking
- `message_limits`: Daily message limit tracking

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Supabase account
- Google AdMob account (for ads)
- App Store/Play Store developer account (for in-app purchases)

### Environment Setup

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   flutter pub get
   \`\`\`

3. Configure Supabase:
   - Create a new Supabase project
   - Run the SQL scripts in `scripts/` folder in order:
     - `01_create_tables.sql`
     - `02_create_functions.sql`
     - `03_seed_interest_categories.sql`
     - `04_setup_rls.sql`
   - Update `lib/core/config/app_config.dart` with your Supabase credentials

4. Configure AdMob:
   - Create AdMob account and app
   - Update ad unit IDs in `lib/core/services/ad_service.dart`

5. Configure In-App Purchases:
   - Set up products in App Store Connect / Google Play Console
   - Update product IDs in `lib/core/services/subscription_service.dart`

### Running the App

\`\`\`bash
# Development
flutter run

# Production build
flutter build apk --release  # Android
flutter build ios --release  # iOS
\`\`\`

## Key Features Implementation

### E2E Encryption
- RSA-2048 for key exchange
- AES-256-GCM for message encryption
- Keys stored in Flutter Secure Storage
- Public keys stored in Supabase for key exchange

### Geolocation Privacy
- Adds ±500m random noise to coordinates
- Stores only approximate location
- Never exposes exact coordinates to other users
- Uses PostGIS for efficient proximity queries

### Message Limits
- Free users: 50 messages/day
- Watch ad: +10 messages
- Premium: Unlimited messages
- Resets daily at midnight UTC

### Gamification
- XP earned for: posting (+10), commenting (+5), liking (+1), chatting (+2)
- Level formula: XP required = level × 100
- Achievements unlock at specific XP thresholds
- Leaderboards per interest category

## Content Moderation

### NSFW Filtering
- Users opt-in to NSFW categories during onboarding
- NSFW posts show warning overlay before viewing
- Separate feeds for each interest category
- Users can report inappropriate content

### Moderation Policy
- Allows adult content with proper warnings (18+)
- Blocks only illegal content (violence, hate speech, illegal activities)
- User reports reviewed by moderators
- Flexible system respects user choice

## Monetization Strategy

### Free Tier
- 50 messages per day
- Ad-supported (banner + rewarded ads)
- Full access to feeds and discovery
- Basic gamification features

### Premium ($2.99/month)
- Unlimited messaging
- Ad-free experience
- Premium badge
- See who viewed your profile
- Priority support

## Security Considerations

1. **Authentication**: Supabase Auth with email/password
2. **Authorization**: Row Level Security (RLS) policies
3. **Encryption**: E2E encryption for all messages
4. **Data Privacy**: Approximate location only, no exact coordinates
5. **Secure Storage**: Encryption keys in Flutter Secure Storage
6. **HTTPS**: All API calls over HTTPS
7. **Input Validation**: Server-side validation for all inputs

## Performance Optimizations

1. **Pagination**: Infinite scroll with limit/offset
2. **Caching**: Local caching with Hive
3. **Image Optimization**: Compressed uploads to Supabase Storage
4. **Lazy Loading**: Load data on demand
5. **Realtime Subscriptions**: Efficient WebSocket connections

## Testing

\`\`\`bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
\`\`\`

## Deployment

### Android
1. Update `android/app/build.gradle` with signing config
2. Build release APK: `flutter build apk --release`
3. Upload to Google Play Console

### iOS
1. Update `ios/Runner.xcodeproj` with signing
2. Build release IPA: `flutter build ios --release`
3. Upload to App Store Connect via Xcode

## License

Proprietary - All rights reserved

## Support

For issues or questions, contact: support@blinkr.app
