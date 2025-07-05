# Google Calendar Integration Setup Guide

This guide explains how to set up Google Calendar integration for the Honey & Thyme Flutter application.

## Overview

The Google Calendar integration allows the admin to:

1. Connect their Google Calendar account
2. Select which calendar to publish events to
3. Automatically create calendar events when photo shoots are scheduled

## Setup Steps

### 1. Google API Console Configuration

1. Go to the [Google API Console](https://console.developers.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Calendar API:

   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Calendar API"
   - Click on it and press "Enable"

4. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - Select "Web application" as the application type
   - Add authorized redirect URIs:
     - For development: `http://localhost:5001/signin-google`
     - For production: `https://your-domain.com/signin-google`
   - Note down your **Client ID** and **Client Secret**

### 2. Update Flutter Configuration

1. Update the `CalendarService` in `lib/src/services/calendar_service.dart`:

   ```dart
   static final GoogleSignIn _googleSignIn = GoogleSignIn(
     serverClientId: 'YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com', // Replace with your client ID
     scopes: <String>[
       'email',
       'https://www.googleapis.com/auth/calendar',
       'https://www.googleapis.com/auth/calendar.events',
     ],
   );
   ```

2. For Android, update `android/app/build.gradle`:

   ```gradle
   defaultConfig {
       // ... other config
       resValue "string", "server_client_id", "YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com"
   }
   ```

3. For iOS, update `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

### 3. Backend API Endpoints

Your C# backend needs to implement these endpoints:

- `GET /calendar/auth-state` - Get current authentication state
- `POST /calendar/exchange-auth-code` - Exchange auth code for tokens
- `GET /calendar/calendars` - Get user's calendars
- `POST /calendar/set-selected` - Set selected calendar
- `POST /calendar/events` - Create calendar event
- `POST /calendar/sign-out` - Sign out and revoke tokens

### 4. Usage

1. **Connect Calendar**:

   - Go to the Admin page
   - Click "Connect Calendar" in the Google Calendar Settings section
   - Follow the Google OAuth flow
   - Select which calendar to use for publishing events

2. **Create Calendar Events**:
   - When creating or editing photo shoots, calendar events will be automatically created
   - Events include client details, shoot information, and location

## Security Notes

- Always use HTTPS in production
- Store tokens securely (encrypted) in your database
- Implement proper token refresh logic
- Handle token expiration gracefully

## Troubleshooting

### Common Issues

1. **"Invalid redirect URI" error**:

   - Ensure the redirect URI in Google Console matches your backend endpoint
   - Check for typos in the URI

2. **"Client ID not found" error**:

   - Verify the client ID is correctly set in the Flutter app
   - Ensure the client ID is for a "Web application" type

3. **Calendar not appearing**:
   - Check that the user has granted calendar access permissions
   - Verify the scopes include calendar access

### Debug Mode

Enable debug logging by adding this to your Flutter app:

```dart
import 'package:google_sign_in/google_sign_in.dart';

// In your main() function
GoogleSignIn.debug = true;
```

## API Reference

### CalendarService Methods

- `getAuthState()` - Get current authentication state
- `initiateGoogleSignIn()` - Start Google OAuth flow
- `exchangeAuthCode(authCode)` - Exchange auth code for tokens
- `getCalendars()` - Get user's calendars
- `setSelectedCalendar(calendarId)` - Set selected calendar
- `createEvent(...)` - Create a calendar event
- `signOut()` - Sign out and revoke tokens

### CalendarEventUtils Methods

- `createPhotoShootEvent(photoShoot)` - Create event from photo shoot
- `isCalendarAvailable()` - Check if calendar integration is ready

## Support

For issues with the Google Calendar integration, check:

1. Google API Console logs
2. Flutter app logs
3. Backend API logs
4. Network connectivity and firewall settings
