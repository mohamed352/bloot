# Bloot Admin Web

React + TypeScript + Vite admin dashboard for Bloot. Manages users, reports, tournaments, games, rooms, streams, economy, achievements, leaderboards, notifications, analytics, and settings.

## Tech Stack

- **Framework**: React 18 + Vite 5
- **Language**: TypeScript
- **Routing**: React Router DOM v6
- **State/Server**: TanStack Query + Zustand
- **Styling**: Tailwind CSS 3
- **Icons**: Material Symbols Outlined
- **Charts**: Chart.js + react-chartjs-2
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Hosting**: Vercel

## Setup

```bash
cd web_admin
cp .env.example .env
npm install
npm run dev
```

## Build

```bash
npm run build
```

## Tests

```bash
npm test
```

## Deploy

```bash
vercel --prod
```

## First-time admin setup

After deploying functions, call `seedFirstSuperAdmin` from the Firebase console or a signed-in client while the `admins` collection is empty. This promotes the caller to super_admin.

## Project Structure

- `src/components/` — reusable UI components
- `src/features/<section>/` — admin section pages
- `src/hooks/` — TanStack Query hooks for Firestore collections
- `src/services/` — Firebase config and admin Cloud Function callers
- `src/stores/` — Zustand stores (auth, toast)
- `src/types/` — shared TypeScript types
- `src/utils/` — formatting and utility helpers
