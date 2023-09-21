# Android
# (Local Build apk.file) :
flutter build apk lib/main.prod.dart --release --build-number 31
# (Build Google aab.file) :
flutter build appbundle lib/main.prod.dart --release --build-number 31

cp -R build/app/outputs/flutter-apk/*.* installation/

