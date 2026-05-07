# Secure Firebase Setup for Web Development

## Overview
Your Flutter app now uses **secure environment variable management** instead of hardcoding API keys.

## How It Works

1. **`.env` file** - Contains your actual Firebase credentials (kept local, NOT committed)
2. **`.env.example`** - Template showing what variables are needed (safe to commit)
3. **`flutter_dotenv` package** - Loads environment variables at runtime
4. **`main.dart`** - Loads the `.env` file before Firebase initialization

## Setup Instructions

### First Time Setup:
```bash
# 1. Install dependencies
flutter pub get

# 2. Copy the example file
cp .env.example .env

# 3. Edit .env with your actual Firebase credentials
nano .env
```

### Running the App

**On Chrome (Web):**
```bash
flutter run -d chrome
```

**On Android:**
```bash
flutter run -d android
```

**On iOS:**
```bash
flutter run -d ios
```

## Security Benefits

✅ **No secrets in git** - `.env` is in `.gitignore`
✅ **No command-line exposure** - No `--dart-define` flags needed
✅ **Safe to share** - `.env.example` can be committed
✅ **Easy team collaboration** - Each dev has their own `.env`
✅ **Production ready** - CI/CD can inject `.env` file securely

## For Team Members

When a new team member clones the repo:
1. They'll see the `.env.example` file
2. They copy it to `.env`: `cp .env.example .env`
3. They fill in their Firebase credentials
4. Everything works without exposing secrets

## For CI/CD Deployment

In your CI/CD pipeline (GitHub Actions, etc.):
```yaml
- name: Create .env file
  run: echo "${{ secrets.ENV_FILE }}" > .env
```

Store the entire `.env` content as a GitHub Secret for safe deployment.
