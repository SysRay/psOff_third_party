@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 ^<install-prefix^> [Debug]
    exit /b 1
)

set "INSTALL_PREFIX=%~1"
set "OPENSSL_REF=openssl-3.6.4"
set "REPO_DIR=projects\OpenSSL"
set "BUILD_TYPE=--release"

if /I "%~2"=="Debug" set "BUILD_TYPE=--debug"
if not exist "%INSTALL_PREFIX%" mkdir "%INSTALL_PREFIX%"
for %%I in ("%INSTALL_PREFIX%") do set "INSTALL_PREFIX=%%~fI"

if exist "%REPO_DIR%\.git" (
    pushd "%REPO_DIR%"
    git fetch --depth=1 origin
    if errorlevel 1 goto :fail
    git reset --hard %OPENSSL_REF%
    if errorlevel 1 goto :fail
    git gc --prune=now
    popd
) else (
    if not exist "projects" mkdir projects
    git clone --depth 1 --branch %OPENSSL_REF% https://github.com/openssl/openssl.git "%REPO_DIR%"
    if errorlevel 1 goto :fail
)

set "PERL_BIN=perl"
if exist "C:\Strawberry\perl\bin\perl.exe" set "PERL_BIN=C:\Strawberry\perl\bin\perl.exe"

set "CONFIGURE_FLAGS=shared no-tests no-apps no-docs no-engine no-dynamic-engine no-legacy no-deprecated no-comp no-idea no-mdc2 no-rc5 no-srp no-psk no-camellia no-cast no-seed no-whirlpool no-blake2 no-siphash no-sm2 no-sm3 no-sm4 no-async no-zlib no-ui-console"

pushd "%REPO_DIR%"

"%PERL_BIN%" Configure VC-WIN64A %CONFIGURE_FLAGS% %BUILD_TYPE% --prefix="%INSTALL_PREFIX%" --openssldir="%INSTALL_PREFIX%\ssl"
if errorlevel 1 (
    popd
    goto :fail
)

nmake %MAKE_ARGS%
if errorlevel 1 (
    popd
    goto :fail
)

nmake install_sw
if errorlevel 1 (
    popd
    goto :fail
)

popd
endlocal
exit /b 0

:fail
endlocal
exit /b 1
