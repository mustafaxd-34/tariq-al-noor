@echo off
setlocal
echo === Tariq Al-Noor Android Release Build ===
flutter doctor
if errorlevel 1 goto :error
flutter pub get
if errorlevel 1 goto :error
flutter analyze
if errorlevel 1 goto :error
flutter test
if errorlevel 1 goto :error
flutter build apk --release
if errorlevel 1 goto :error
echo.
echo APK created at: build\app\outputs\flutter-apk\app-release.apk
pause
exit /b 0
:error
echo Build failed. Review the error above.
pause
exit /b 1
