# Bloot Bot Harness

A standalone Node.js tool that fills the other 3 seats in a Bloot room with autonomous bots, so a solo developer can test the full online 4-player game loop without finding other human players.

> **Recommended for single-device testing:** Use the in-app **Play with Bots** button on the home screen. It creates a real Firestore room with you + 3 bots and starts the game automatically. This harness is an advanced/manual alternative for existing rooms.

## What it does

1. Signs in 3 anonymous bot users (`Faisal`, `Omar`, `Khalid`).
2. Joins them to a room using its 6-character invite code.
3. Toggles each bot to **Ready**.
4. Watches the game document and automatically acts on each bot's turn:
   - **Bidding:** bids Hokm/Sun/Pass using a simple random-but-legal strategy.
   - **Bonus claim:** auto-detects Bnaga/Mosal and claims them in Hokm mode.
   - **Trick play:** plays the lowest legal card.
   - **Round end:** triggers the next round.

## Prerequisites

- Node.js 18+
- A Bloot room invite code (create one from the app)
- For emulator use: Firebase emulator suite running (`firebase emulators:start` from project root)
- For production use: a Firebase Web API key for the target project

## Setup

```bash
cd tools/bot_harness
npm install
```

## Usage

### Quick: in-app Play with Bots (recommended)

Tap **Play with Bots** on the home screen. The app creates a real room, adds 3 bots, and starts the game automatically. No harness required.

### Manual harness against the Firebase emulator

1. Start the emulator suite in the project root:
   ```bash
   firebase emulators:start
   ```

2. Launch the Flutter app and create a private room. Copy the 6-character invite code (e.g. `ABCD12`).

3. Run the harness with `--emulator`:
   ```bash
   npm run start -- --emulator ABCD12
   # or during development
   npx ts-node src/index.ts --emulator --code ABCD12
   ```

### Manual harness against production Firebase

```bash
npx ts-node src/index.ts --code ABCD12 --apiKey YOUR_WEB_API_KEY
```

On PowerShell, npm may consume `--code`. If you see `Unknown cli config "--code"`,
pass the code as a positional argument instead:
```powershell
npm run start -- ABCD12
# or
npm run start -- "--code=ABCD12"
```

4. In the app, tap **Start Game** once all 4 players are ready. The bots will play automatically.

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--code`, `-c` | Room invite code (required) | — |
| `--emulator` | Use the local Firebase Emulator Suite | false |
| `--project` | Firebase project ID | `bloot-89b2b` |
| `--apiKey` | Firebase Web API key (required for production) | — |
| `--host` | Emulator host | `localhost` |

## Notes

- Emulator ports: Auth `9099`, Firestore `8080`, Functions `5001`.
- Bots sign in anonymously, so the Auth backend must allow anonymous sign-in.
- The harness does **not** join Agora voice/video channels, so you can still test voice/video separately with the human seat.

## Extending

- Edit `src/index.ts` to change bot strategy (e.g. make bots bid/raise more aggressively).
- Add `--count N` to support fewer or more bots.
- Add `--auto-start` to have the harness call `startGame` itself when 4 players are ready (currently the host must start).
