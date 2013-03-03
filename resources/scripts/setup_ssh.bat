@echo off
if not exist "%homedrive%%homepath%\.ssh" mkdir "%homedrive%%homepath%\.ssh"
if not exist "%homedrive%%homepath%\.ssh\id_rsa.pub" c:\RailsInstaller\Git\bin\ssh-keygen.exe -f "%homedrive%%homepath%\.ssh\id_rsa" -t rsa -N ""
@echo on