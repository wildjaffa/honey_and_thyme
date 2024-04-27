flutter build web --web-renderer canvaskit --release
# flutter build apk --release
# flutter build apk --debug
# copy and overwrite release build to Z:\mindful-measures\web-build
$versionString = Get-Date -Format "d-h-m-s-fff"
((Get-Content -Path build/web/index.html -Raw) -replace 'main.dart.js', "main.dart.js?v=${versionString}") | Set-Content -Path build/web/index.html
Copy-Item -Path "build/web/*" -Destination "Z:\honeyAndThyme\web" -Recurse -Force
# Remove-Item -Path "build\app\outputs\flutter-apk\release.zip"
# Remove-Item -Path "build\app\outputs\flutter-apk\debug.zip"
# 7z a -tzip build\app\outputs\flutter-apk\release.zip build\app\outputs\flutter-apk\app-release.apk -pBeOurGuest+Help
# 7z a -tzip build\app\outputs\flutter-apk\debug.zip build\app\outputs\flutter-apk\app-debug.apk -pBeOurGuest+Help
# Copy-Item -Path "build\app\outputs\flutter-apk\release.zip" -Destination "Z:\mindful-measures\web-build\builds" -Force
# Copy-Item -Path "build\app\outputs\flutter-apk\debug.zip" -Destination "Z:\mindful-measures\web-build\builds\debug" -Force
