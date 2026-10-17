@echo off
setlocal
cd /d "%~dp0"
if not defined PORT set "PORT=3000"
if not defined FDE_RUNTIME_DIR set "FDE_RUNTIME_DIR=%~dp0.runtime"
set "FDE_NODE=%FDE_RUNTIME_DIR%\node.exe"
set "FDE_ARCHIVE=%~dp0runtime\node-v24.19.0-win-x64.zip"
set "FDE_PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%FDE_NODE%" (
  if not exist "%FDE_ARCHIVE%" goto missing
  echo Preparing the included Windows runtime on first launch...
  "%FDE_PS%" -NoProfile -NonInteractive -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead($env:FDE_ARCHIVE); try { [IO.Directory]::CreateDirectory($env:FDE_RUNTIME_DIR) | Out-Null; foreach($n in @('node.exe','LICENSE')) { $e=$z.GetEntry($n); if(!$e){throw ('Missing '+$n)}; [IO.Compression.ZipFileExtensions]::ExtractToFile($e,([IO.Path]::Combine($env:FDE_RUNTIME_DIR,$n)),$true) } } finally { $z.Dispose() }"
  if errorlevel 1 goto failed
)
"%FDE_NODE%" --version >nul 2>&1
if errorlevel 1 goto failed
set "FDE_UI_URL=http://127.0.0.1:%PORT%/"
echo Starting the local app at %FDE_UI_URL%
if "%FDE_SMOKE_TEST%"=="1" (
  "%FDE_NODE%" -e "const {server}=require('./server');server.listen(Number(process.env.PORT),'127.0.0.1');setTimeout(()=>server.close(),8000)"
  if errorlevel 1 goto failed
  exit /b 0
)
if not "%FDE_NO_BROWSER%"=="1" start "" /b "%FDE_PS%" -NoProfile -NonInteractive -Command "$u=$env:FDE_UI_URL; for($i=0;$i -lt 60;$i++){try{if((Invoke-WebRequest -UseBasicParsing -Uri ($u+'api/health') -TimeoutSec 1).StatusCode -eq 200){Start-Process $u;break}}catch{};Start-Sleep -Milliseconds 250}"
"%FDE_NODE%" server.js
if errorlevel 1 goto failed
exit /b 0
:missing
echo The included runtime archive is missing: %FDE_ARCHIVE%
goto failed
:failed
echo Startup failed. Keep this window open and check the message above.
pause
exit /b 1
