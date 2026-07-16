# QA Test Checklist — Bloot

Use this checklist for every QA build before releasing to testers.

## 1. Installation & Launch

- [ ] APK installs without errors on a real Android device
- [ ] App launches to splash screen, then navigates to onboarding/welcome
- [ ] No crash on cold start or warm start
- [ ] App icon and splash screen display correctly

## 2. Authentication

- [ ] Phone number entry accepts valid formats
- [ ] OTP verification screen appears after phone submission
- [ ] Valid OTP logs the user in
- [ ] Invalid OTP shows an error message
- [ ] Resend OTP works
- [ ] Profile completion screen saves display name and avatar
- [ ] Logout returns to login screen

## 3. Home Screen

- [ ] Home screen loads with correct navigation tabs
- [ ] User avatar and name display in header
- [ ] Quick action buttons (Create Room, Join Room, Discover) are visible and tappable

## 4. Room Creation & Lobby

- [ ] Create Room page renders with name field, room type selector, and toggles
- [ ] Private room shows password field; Public and Live Stream hide it
- [ ] Private room with password < 4 chars disables Create button
- [ ] Voice, Camera, and Spectators toggles work
- [ ] Creating a room navigates to Room Lobby
- [ ] Lobby shows room code, player slots, and Ready button
- [ ] Invite code can be copied to clipboard
- [ ] Ready/Not Ready toggle works
- [ ] Start Game button appears when all players are ready (host only)
- [ ] Bots can be invited to fill empty slots

## 5. Join Room

- [ ] Join Room page accepts an invite code
- [ ] Paste from Clipboard button works
- [ ] Private room prompts for password before joining
- [ ] Invalid code shows error message
- [ ] Successful join navigates to Room Lobby

## 6. Game Play (WebView)

- [ ] Game starts and WebView loads the game board
- [ ] Cards are displayed in player's hand
- [ ] Tapping a card plays it to the table
- [ ] Turn indicator shows whose turn it is
- [ ] Trick winner is determined and announced
- [ ] Round end screen shows scores
- [ ] Game end screen shows winner and rematch option
- [ ] Rematch restarts a new game
- [ ] Leaving game returns to home/lobby

## 7. Live Streaming

- [ ] Host can start a live stream from a Live Stream room
- [ ] Stream appears in Discover Streams page
- [ ] Viewer can tap a stream to watch
- [ ] Watch stream page shows video grid, stream title, host name, viewer count
- [ ] Chat messages can be sent and received during stream
- [ ] Host can end the stream
- [ ] Stream viewer count updates in real-time

## 8. Voice / Video (Agora)

- [ ] Voice chat works in room lobby and during game
- [ ] Mic toggle mutes/unmutes microphone
- [ ] Camera toggle enables/disables video
- [ ] Speaker detection (active speaker indicator) works
- [ ] Joining/leaving Agora channel does not crash
- [ ] Audio continues when app is in background (if enabled)

## 9. Chat

- [ ] In-room chat messages send and display correctly
- [ ] Stream chat messages send and display correctly
- [ ] Chat input clears after sending
- [ ] Chat shows sender name and avatar (if available)

## 10. Discover

- [ ] Discover Streams page loads with available streams
- [ ] Empty state shows "No live streams" message
- [ ] Tapping a stream navigates to watch page

## 11. Settings & Profile

- [ ] Settings page opens
- [ ] Sound effects toggle works
- [ ] Background music toggle works
- [ ] Auto-rotate toggle works
- [ ] Profile can be edited

## 12. Error Handling

- [ ] Network errors show user-friendly messages (not raw exceptions)
- [ ] App recovers from temporary network loss
- [ ] Firebase errors are handled gracefully

## 13. Performance

- [ ] No jank during navigation transitions
- [ ] WebView game runs smoothly (no freezing)
- [ ] App does not drain battery excessively during gameplay
- [ ] Memory usage is stable over extended play sessions

## 14. Feedback (Firebase App Distribution)

- [ ] In-app feedback notification appears (if App Distribution SDK is active)
- [ ] Feedback can be submitted with screenshot

## Sign-off

- **Tester Name**: _______________
- **Build Version**: _______________
- **Date**: _______________
- **Overall Result**: [ ] Pass  [ ] Fail
- **Notes**: _________________________________________________
