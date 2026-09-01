FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

ARG SUPABASE_URL=
ARG SUPABASE_ANON_KEY=
ARG EVENT_LINK_BASE_URL=

ENV MAX_APK_SIZE_MB=35 \
    SUPABASE_URL=$SUPABASE_URL \
    SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
    EVENT_LINK_BASE_URL=$EVENT_LINK_BASE_URL

COPY . .

# pubspec.yaml declares .env as an asset, but secrets must not be copied into the image.
RUN test -f .env || touch .env
RUN flutter pub get

VOLUME ["/app/build"]

CMD ["bash", "-lc", "set -euo pipefail; \
  flutter build appbundle --release \
    --dart-define=SUPABASE_URL=\"$SUPABASE_URL\" \
    --dart-define=SUPABASE_ANON_KEY=\"$SUPABASE_ANON_KEY\" \
    --dart-define=EVENT_LINK_BASE_URL=\"$EVENT_LINK_BASE_URL\"; \
  flutter build apk --release --split-per-abi \
    --dart-define=SUPABASE_URL=\"$SUPABASE_URL\" \
    --dart-define=SUPABASE_ANON_KEY=\"$SUPABASE_ANON_KEY\" \
    --dart-define=EVENT_LINK_BASE_URL=\"$EVENT_LINK_BASE_URL\"; \
  max_bytes=$((MAX_APK_SIZE_MB * 1024 * 1024)); \
  apks=(build/app/outputs/flutter-apk/*-release.apk); \
  test \"${#apks[@]}\" -gt 0; \
  for apk in \"${apks[@]}\"; do \
    size_bytes=$(stat -c '%s' \"$apk\"); \
    size_mb=$(awk \"BEGIN {printf \\\"%.2f\\\", $size_bytes / 1048576}\"); \
    printf '%s: %s MB\\n' \"$apk\" \"$size_mb\"; \
    test \"$size_bytes\" -le \"$max_bytes\" || { printf 'APK exceeds MAX_APK_SIZE_MB=%s: %s\\n' \"$MAX_APK_SIZE_MB\" \"$apk\" >&2; exit 1; }; \
  done; \
  apk=$(find build/app/outputs/flutter-apk -name '*-arm64-v8a-release.apk' -print -quit); \
  test -n \"$apk\"; \
  mkdir -p build/reports; \
  apkanalyzer=$(find \"$ANDROID_HOME\" -type f -name apkanalyzer -print -quit); \
  test -n \"$apkanalyzer\"; \
  \"$apkanalyzer\" apk file-size \"$apk\" | tee build/reports/arm64-apk-size.txt; \
  unzip -l \"$apk\" | awk '/\\.so$/ {print}' | sort -k1,1nr > build/reports/arm64-native-libraries.txt; \
  cat build/reports/arm64-native-libraries.txt"]