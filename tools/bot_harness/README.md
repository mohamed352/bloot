# Bloot Bot Harness

A standalone Node.js tool that fills the other 3 seats in a Bloot room with autonomous bots, so a solo developer can test the full online 4-player game loop without finding other human players.

## What it does

1. Connects to the Firebase emulator (or production project if configured).
2. Signs in 3 anonymous bot users (`Faisal`, `Omar`, `Khalid`).
3. Joins them to a room using its 6-character invite code.
4. Toggles each bot to **Ready**.
5. Watches the game document and automatically acts on each bot's turn:
   - **Bidding:** bids Hokm/Sun/Pass using a simple random-but-legal strategy.
   - **Bonus claim:** auto-detects Bnaga/Mosal and claims them in Hokm mode.
   - **Trick play:** plays the lowest legal card.
   - **Round end:** triggers the next round.

## Prerequisites

- Node.js 18+
- Firebase emulator suite running (`firebase emulators:start` from project root)
- Flutter app configured to use the emulator in debug builds

## Setup

```bash
cd tools/bot_harness
npm install
```

## Usage

1. Start the emulator suite in the project root:
   ```bash
   firebase emulators:start
   ```

2. Launch the Flutter app and create a private room. Copy the 6-character invite code (e.g. `ABCD12`).

   Or seed a test room without the app:
   ```bash
   npx ts-node scripts/seedRoom.ts TEST12
   ```

3. Run the harness:
   ```bash
   npm run start -- ABCD12
   # or during development
   npx ts-node src/index.ts --code ABCD12
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
| `--project` | Firebase project ID | `bloot-89b2b` |
| `--host` | Emulator host | `localhost` |

## Notes

- The harness is hardcoded to use emulator ports: Auth `9099`, Firestore `8080`, Functions `5001`.
- Bots sign in anonymously, so the Auth emulator must allow anonymous sign-in (default in emulator).
- The harness does **not** join Agora voice/video channels, so you can still test voice/video separately with the human seat.
- To run against production, replace the emulator connections with your production Firebase config and ensure the bots can authenticate.

## Extending

- Edit `src/index.ts` to change bot strategy (e.g. make bots bid/raise more aggressively).
- Add `--count N` to support fewer or more bots.
- Add `--auto-start` to have the harness call `startGame` itself when 4 players are ready (currently the host must start).
