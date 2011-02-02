@ECHO OFF

REM
REM Environment setup file for RailsInstaller.
REM

REM
REM First we Determine where is RUBY_DIR
REM (which is where this script is)
REM
PUSHD %~dp0.
SET RUBY_DIR=%CD%
POPD

REM
REM Now we Determine the RailsInstaller Root directory
REM (parent directory of Ruby)
REM
PUSHD %RUBY_DIR%\..
SET ROOT_DIR=%CD%
POPD

REM
REM Add RUBY_DIR\bin to the PATH, DevKit\bin and then Git\cmd
REM RUBY_DIR\bin takes higher priority to avoid other tools conflict
REM
SET PATH=%RUBY_DIR%\bin;%RUBY_DIR%lib\ruby\gems\1.8\bin;%ROOT_DIR%\DevKit\bin;%ROOT_DIR%\Git\cmd;%PATH%
SET RUBY_DIR=
SET ROOT_DIR=

REM
REM Create the HOME\Sites directory.
REM
IF NOT EXIST %HOMEDRIVE%\Sites. (md %HOMEDRIVE%\Sites.)

REM
REM Set the HOME environment variables for Ruby & Gems to use
REM with ENV["HOME"]
REM
SET HOME=%HOMEDRIVE%%HOMEPATH%

REM Display Git Verison
git --version

REM Display Ruby Version
%RUBY_DIR%\bin\ruby.exe -v

REM Display Rails version
%RUBY_DIR%\bin\rails.bat -v

REM NOTE we start out in the Sites directory as that is the working dir set.
REM cd %HOMEDRIVE%\Sites

