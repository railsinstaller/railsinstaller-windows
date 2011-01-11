@ECHO OFF
REM Determine where is RUBY_BIN (where this script is)
PUSHD %~dp0.
SET RUBY_BIN=%CD%
POPD

REM Now determine Root (.. from RUBY_BIN)
PUSHD %RUBY_BIN%\..
SET ROOT_DIR=%CD%
POPD

REM Add RUBY_BIN to the PATH, DevKit and then Git
REM RUBY_BIN takes higher priority to avoid other tools conflict
SET PATH=%RUBY_BIN%;%ROOT_DIR%\DevKit;%ROOT_DIR%\Git\cmd;%PATH%
SET RUBY_BIN=
SET ROOT_DIR=

REM Display Ruby version and Git versions
ruby.exe -v
git --version
