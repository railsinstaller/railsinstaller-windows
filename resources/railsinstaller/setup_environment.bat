@ECHO OFF

REM
REM Environment setup file for RailsInstaller.
REM

REM
REM First we Determine where is RUBY_DIR (which is where this script is)
REM
PUSHD %~dp0.
SET RUBY_DIR=%CD%
POPD

REM
REM Now Determine the RailsInstaller Root directory (parent directory of Ruby)
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
REM Set the HOME environment variables for Ruby & Gems to use with ENV["HOME"]
REM
SET HOME=%HOMEDRIVE%%HOMEPATH%

REM Check configurations for Git and SSH
ruby %1\scripts\config_check.rb
ruby.exe "require 'rbconfig' ; file=%%\"#{RbConfig::CONFIG['bindir']}/../../scripts/config_check.rb\" ; load file"

REM NOTE that we start out in the Sites directory as the current working dir
REM cd %HOMEDRIVE%\Sites

