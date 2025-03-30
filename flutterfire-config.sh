#!/bin/bash
#chmod +x flutterfire-config.sh

# Tên project Firebase trên Firebase Console
FIREBASE_PROJECT_ID="retrotrix-e7c34"

# Cấu hình Dev
flutterfire configure \
  --project=$FIREBASE_PROJECT_ID \
  --out=lib/firebase_options_dev.dart \
  --android-package-name=com.example.aa_teris.dev \
  --android-out=android/app/src/dev/google-services.json

# Cấu hình Staging
flutterfire configure \
  --project=$FIREBASE_PROJECT_ID \
  --out=lib/firebase_options_stag.dart \
  --android-package-name=com.example.aa_teris.stag \
  --android-out=android/app/src/stag/google-services.json

# Cấu hình Production (Không cần thêm .prod)
flutterfire configure \
  --project=$FIREBASE_PROJECT_ID \
  --out=lib/firebase_options_prod.dart \
  --android-package-name=com.example.aa_teris \
  --android-out=android/app/src/google-services.json

echo "✅ Firebase đã được cấu hình thành công cho các môi trường: dev, stag, prod!"
