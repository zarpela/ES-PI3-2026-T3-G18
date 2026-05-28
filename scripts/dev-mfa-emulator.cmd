@echo off
setlocal

cd /d "%~dp0.."

echo Installing backend deps (functions)...
call npm.cmd --prefix functions install
if errorlevel 1 exit /b 1

echo Building backend (functions)...
call npm.cmd --prefix functions run build
if errorlevel 1 exit /b 1

echo Starting Firebase emulators (firestore,functions)...
call firebase.cmd emulators:start --only firestore,functions

endlocal

