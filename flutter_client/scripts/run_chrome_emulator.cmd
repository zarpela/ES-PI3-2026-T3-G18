@echo off
setlocal

cd /d "%~dp0.."

set "API_BASE_URL=http://127.0.0.1:5002/projetointegrador3-grupo18/southamerica-east1/api/"
echo Running Flutter on Chrome with API_BASE_URL=%API_BASE_URL%

call flutter run -d chrome --dart-define=API_BASE_URL=%API_BASE_URL%

endlocal

