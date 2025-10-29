# Blinkr V2 - Complete Setup Guide

This guide will walk you through setting up the complete Blinkr V2 application from scratch.

## Step 1: Prerequisites

### Required Software
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio or Xcode (for mobile development)
- Git
- A code editor (VS Code recommended)

### Required Accounts
- Supabase account (free tier available)
- Google AdMob account
- Apple Developer account (for iOS)
- Google Play Developer account (for Android)

## Step 2: Supabase Setup

### 2.1 Create Supabase Project
1. Go to https://supabase.com
2. Sign up or log in
3. Click "New Project"
4. Fill in project details:
   - Name: Blinkr
   - Database Password: (save this securely)
   - Region: Choose closest to your users
5. Wait for project to be created

### 2.2 Enable PostGIS Extension
1. In Supabase dashboard, go to "Database" → "Extensions"
2. Search for "postgis"
3. Click "Enable" on the postgis extension

### 2.3 Run Database Scripts
1. Go to "SQL Editor" in Supabase dashboard
2. Run each script in order:
   - Copy content from `scripts/01_create_tables.sql`
   - Click "Run"
   - Repeat for `02_create_functions.sql`
   - Repeat for `03_seed_interest_categories.sql`
   - Repeat for `04_setup_rls.sql`

### 2.4 Get API Credentials
1. Go to "Settings" → "API"
2. Copy the following:
   - Project URL
   - anon/public key
3. Update `lib/core/config/app_config.dart`:
   \`\`\`dart
   static const String supabaseUrl = 'YOUR_PROJECT_URL';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY';
   \`\`\`

### 2.5 Configure Storage
1. Go to "Storage" in Supabase dashboard
2. Create buckets:
   - `avatars` (public)
   - `post-images` (public)
3. Set up storage policies for authenticated uploads

## Step 3: Google AdMob Setup

### 3.1 Create AdMob Account
1. Go to https://admob.google.com
2. Sign up with Google account
3. Complete account setup

### 3.2 Create App
1. Click "Apps" → "Add App"
2. Select platform (Android/iOS)
3. Enter app name: "Blinkr"
4. Note the App ID

### 3.3 Create Ad Units
1. Go to "Ad units" → "Add ad unit"
2. Create "Rewarded" ad unit
3. Name it "Message Unlock Reward"
4. Note the Ad Unit ID

### 3.4 Update App Configuration
1. For Android, update `android/app/src/main/AndroidManifest.xml`:
   \`\`\`xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
   \`\`\`

2. For iOS, update `ios/Runner/Info.plist`:
   \`\`\`xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
   \`\`\`

3. Update `lib/core/services/ad_service.dart`:
   \`\`\`dart
   static const String _rewardedAdUnitId = 'YOUR_AD_UNIT_ID';
   \`\`\`

## Step 4: In-App Purchase Setup

### 4.1 Google Play Console (Android)
1. Go to Google Play Console
2. Create app if not exists
3. Go to "Monetize" → "Products" → "Subscriptions"
4. Create subscription:
   - Product ID: `blinkr_premium_monthly`
   - Name: "Blinkr Premium"
   - Price: $2.99
   - Billing period: 1 month

### 4.2 App Store Connect (iOS)
1. Go to App Store Connect
2. Create app if not exists
3. Go to "Features" → "In-App Purchases"
4. Create Auto-Renewable Subscription:
   - Reference Name: "Blinkr Premium Monthly"
   - Product ID: `blinkr_premium_monthly`
   - Subscription Group: Create new group
   - Price: $2.99
   - Duration: 1 month

### 4.3 Update App Configuration
Product IDs are already configured in `lib/core/services/subscription_service.dart`

## Step 5: Flutter Project Setup

### 5.1 Clone and Install
\`\`\`bash
# Clone the repository (or use the generated code)
cd blinkr-flutter

# Install dependencies
flutter pub get

# Check for issues
flutter doctor
\`\`\`

### 5.2 Configure Android
1. Update `android/app/build.gradle`:
   \`\`\`gradle
   android {
       compileSdkVersion 34
       
       defaultConfig {
           applicationId "com.blinkr.app"
           minSdkVersion 21
           targetSdkVersion 34
           versionCode 1
           versionName "1.0.0"
       }
   }
   \`\`\`

2. Add permissions in `android/app/src/main/AndroidManifest.xml`:
   \`\`\`xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   \`\`\`

### 5.3 Configure iOS
1. Update `ios/Runner/Info.plist`:
   \`\`\`xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to show nearby users</string>
   <key>NSLocationAlwaysUsageDescription</key>
   <string>We need your location to show nearby users</string>
   \`\`\`

2. Set minimum iOS version in `ios/Podfile`:
   \`\`\`ruby
   platform :ios, '12.0'
   \`\`\`

## Step 6: Testing

### 6.1 Run on Emulator/Simulator
\`\`\`bash
# Android
flutter run

# iOS
flutter run
\`\`\`

### 6.2 Test Features
1. **Authentication**: Sign up with email/password
2. **Interest Selection**: Choose at least 3 interests
3. **Discovery**: Enable location and view nearby users
4. **Feeds**: View posts in different categories
5. **Chat**: Send messages (test E2E encryption)
6. **Gamification**: Check XP and levels
7. **Ads**: Test rewarded ad for message unlock
8. **Premium**: Test subscription flow (use test mode)

## Step 7: Production Deployment

### 7.1 Android Release
\`\`\`bash
# Generate keystore
keytool -genkey -v -keystore ~/blinkr-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias blinkr

# Update android/key.properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=blinkr
storeFile=/path/to/blinkr-key.jks

# Build release APK
flutter build apk --release

# Or build App Bundle
flutter build appbundle --release
\`\`\`

### 7.2 iOS Release
\`\`\`bash
# Build iOS release
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# Archive and upload to App Store Connect
\`\`\`

### 7.3 Update Supabase for Production
1. Review and tighten RLS policies
2. Set up database backups
3. Configure custom domain (optional)
4. Enable database connection pooling
5. Set up monitoring and alerts

## Step 8: Post-Launch

### 8.1 Monitoring
- Set up Sentry or Firebase Crashlytics for error tracking
- Monitor Supabase dashboard for database performance
- Track AdMob revenue and fill rates
- Monitor subscription metrics

### 8.2 Maintenance
- Regular database backups
- Update dependencies monthly
- Monitor user feedback
- Iterate on features based on usage data

## Troubleshooting

### Common Issues

**Issue**: Supabase connection fails
- Check API credentials in `app_config.dart`
- Verify internet connection
- Check Supabase project status

**Issue**: Location not working
- Verify permissions in AndroidManifest.xml / Info.plist
- Check device location settings
- Test on physical device (not emulator)

**Issue**: Ads not showing
- Verify AdMob app ID and ad unit IDs
- Check AdMob account status
- Use test ad IDs during development

**Issue**: In-app purchases not working
- Verify product IDs match exactly
- Check app is signed with correct certificate
- Test with sandbox accounts
- Ensure billing is set up in console

## Support

For additional help:
- Flutter documentation: https://flutter.dev/docs
- Supabase documentation: https://supabase.com/docs
- AdMob help: https://support.google.com/admob
- In-app purchase guide: https://pub.dev/packages/in_app_purchase

## Next Steps

After successful setup:
1. Customize branding and colors in `theme_config.dart`
2. Add custom interest categories if needed
3. Configure content moderation rules
4. Set up analytics tracking
5. Create marketing materials
6. Plan user acquisition strategy
