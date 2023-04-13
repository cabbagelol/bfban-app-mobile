#
# 下发打包
#


# Android
# flutter build apk ./lib/main.prod.dart --release --obfuscate --split-debug-info=build/debug_info
# (Google) :
# flutter build appbundle ./lib/main.prod.dart --release --build-number 6

# Ios
# (Apple) :
# flutter build ipa ./lib/main.prod.dart --release --build-number 6
# xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey your_api_key --apiIssuer your_issuer_id