@ECHO OFF
REM Determine where is RUBY_DIR (which is where this script is)
PUSHD %~dp0.
SET RUBY_DIR=%CD%
POPD

REM Determine RailsInstaller Root (parent directory of Ruby)
PUSHD %RUBY_DIR%\..
SET ROOT_DIR=%CD%
POPD

REM Add RUBY_DIR\bin to the PATH, DevKit\bin and then Git\cmd
REM RUBY_DIR\bin takes higher priority to avoid other tools conflict
SET PATH=%RUBY_DIR%\bin;%ROOT_DIR%\DevKit\bin;%ROOT_DIR%\Git\cmd;%PATH%
SET RUBY_DIR=
SET ROOT_DIR=

REM Display Ruby and Git version
git --version
ruby.exe -v
rails -v

REM NOTE we start out in the Sites directory as that is the working dir set.
