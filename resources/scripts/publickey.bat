@echo off
if exist "%HOMEDRIVE%%HOMEPATH%\.ssh\id_rsa.pub" (
  clip < "%HOMEDRIVE%%HOMEPATH%\.ssh\id_rsa.pub"
  echo Your public ssh key has been copied to your clipboard.
)
@echo on
