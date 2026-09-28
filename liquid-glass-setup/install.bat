@echo off
rem Installe le look Liquid Glass sur un telephone Android ou l'emulateur (Windows).
rem Lancement : double-clic sur ce fichier.
chcp 65001 >nul
cd /d "%~dp0"

rem 1. Trouver adb (installe avec Android Studio)
set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not exist "%ADB%" (
    where adb >nul 2>nul && set "ADB=adb"
)
if not exist "%ADB%" if not "%ADB%"=="adb" (
    echo adb introuvable. Installe Android Studio ^(il contient adb^), puis relance.
    pause
    exit /b 1
)

rem 2. Verifier qu'un appareil est branche
"%ADB%" get-state 2>nul | findstr /c:"device" >nul
if errorlevel 1 (
    echo Aucun appareil detecte ^(ou plusieurs^).
    echo - Emulateur : lance-le depuis Android Studio.
    echo - Telephone : active le debogage USB et accepte l'autorisation sur l'ecran.
    pause
    exit /b 1
)
echo Appareil detecte.

rem 3. APK locaux eventuels (dossier apks\ a cote du script)
if exist "apks\*.apk" (
    for %%f in ("apks\*.apk") do (
        echo Installation de %%~nxf...
        "%ADB%" install -r "%%f"
    )
)

rem 4. Apps du Play Store listees dans apps.txt
for /f "usebackq eol=# tokens=1" %%p in ("apps.txt") do call :installer %%p

rem 5. Choisir l'ecran d'accueil par defaut
echo.
echo Derniere etape : choisis "Liquid Launcher" comme ecran d'accueil sur l'appareil.
"%ADB%" shell am start -a android.settings.HOME_SETTINGS >nul 2>nul
echo Ensuite, dans Liquid Launcher, choisis le pack d'icones iLiquid Dark.
echo Termine.
pause
exit /b 0

:installer
"%ADB%" shell pm list packages %1 2>nul | findstr /c:"package:%1" >nul
if not errorlevel 1 (
    echo OK  %1 deja installee
    exit /b 0
)
echo --^> Ouverture de %1 dans le Play Store...
"%ADB%" shell am start -a android.intent.action.VIEW -d "market://details?id=%1" 2>&1 | findstr /c:"Starting" >nul
if errorlevel 1 "%ADB%" shell am start -a android.intent.action.VIEW -d "https://play.google.com/store/apps/details?id=%1" >nul 2>nul
echo     Appuie sur "Installer" sur l'appareil, puis sur une touche ici...
pause >nul
exit /b 0
