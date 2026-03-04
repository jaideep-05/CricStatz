# CricStatz Website

This folder contains a small static landing page that you can host on the web to let users download the CricStatz mobile app.

## Structure

- `index.html` – main landing page with:
  - Hero section describing CricStatz.
  - A **Download Android APK** button.
  - A note explaining where to place the APK file.

## How to use

1. **Build a release APK** of your Flutter app:

   ```bash
   cd app
   flutter build apk --release
   ```

   This will create something like:

   - `app/build/app/outputs/flutter-apk/app-release.apk`

2. **Copy the APK into this website folder**, for example:

   ```bash
   mkdir -p website/downloads
   cp app/build/app/outputs/flutter-apk/app-release.apk website/downloads/CricStatz-latest.apk
   ```

   The `index.html` file already points the download button to:

   - `downloads/CricStatz-latest.apk`

3. **Host the `website/` folder** with any static hosting provider:

   - GitHub Pages
   - Netlify / Vercel
   - AWS S3 + CloudFront
   - Any regular web server that can serve static files

   The document root for the site should be this `website` directory so that:

   - `https://your-domain/` → `index.html`
   - `https://your-domain/downloads/CricStatz-latest.apk` → APK file

4. **Share the URL**

   Users can visit your site in the browser, tap **Download Android APK**, and install the app on their devices (they may have to allow installs from unknown sources).

## Notes

- The page is pure HTML/CSS (no build step required).
- You can customize branding, colors, and copy directly in `index.html`.

