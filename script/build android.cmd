# Android
# (Local Build apk.file) :
flutter build apk lib/main.prod.dart --release --build-number 15
# (Build Google aab.file) :
# flutter build appbundle lib/main.prod.dart --release --build-number 15

cp -R build/app/outputs/flutter-apk/*.* installation/