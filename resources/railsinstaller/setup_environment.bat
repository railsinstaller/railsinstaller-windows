@ECHO OFF

REM
REM Environment setup file for RailsInstaller.
REM

REM
REM First we determine where is RUBY_DIR (which is where this script is)
REM
PUSHD %~dp0.
SET RUBY_DIR=%CD%
POPD

REM
REM Now determine the RailsInstaller root directory (parent directory of Ruby)
REM
PUSHD %RUBY_DIR%\..
SET ROOT_DIR=%CD%
POPD

REM
REM Add RUBY_DIR\bin to the PATH, DevKit\bin and then Git\cmd
REM RUBY_DIR\bin takes higher priority to avoid other tools conflict
REM
SET PATH=%RUBY_DIR%\bin;%RUBY_DIR%\lib\ruby\gems\1.9.1\bin;%ROOT_DIR%\DevKit\bin;%PATH%
IF EXIST %ROOT_DIR%\Git\cmd SET PATH=%ROOT_DIR%\Git\cmd;%PATH%
SET RUBY_DIR=
SET ROOT_DIR=

REM
REM Create the %HOMEDRIVE%\Sites directory.
REM
IF NOT EXIST %HOMEDRIVE%\Sites MD %HOMEDRIVE%\Sites

REM
REM Set the HOME environment variables for Ruby & Gems to use with ENV["HOME"]
REM
SET HOME=%HOMEDRIVE%%HOMEPATH%

SET RailsInstallerPath=%1
REM Check configurations for Git and SSH
IF EXIST %RailsInstallerPath% (
  ruby %RailsInstallerPath%\scripts\config_check.rb
) ELSE (
  ruby.exe "require 'rbconfig' ; file=%%\#{RbConfig::}"
)

REM NOTE that we start out in the Sites directory as the current working dir
IF EXIST %HOMEDRIVE%\Sites CD %HOMEDRIVE%\Sites
