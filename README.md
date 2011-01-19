# RailsInstaller

Rails development environment installer for Windows

## Overview

The goal of this project is to generate an installer that when run installs all
of the most common components for a Rails development environment with no
required prerequisites on a Windows system.

## How to Contribute

RailsInstaller is bootstrapped, built and packaged via rake tasks.

1. Download and install the latest RailsInstaller from
   http://railsinstaller.org/


2. Bootstrap the project, from the project root run

  > rake bootstrap

3. Install latest Inno Setup Quick Start Pack, ensure iscc.exe is in your PATH

   http://www.jrsoftware.org/isdl.php#qsp

4. [[ hackety hack... ]]


5. Download and build all components on the stage

  > rake build

6. Use Inno Setup to package RailsInstaller

  > rake package

7. Use the generated RailsInstaller.exe, be happy and prosperous! Be
   sure to share it with all of your friends!

### Development Kit (DevKit)

A MSYS/MinGW based toolkit that enables RailsInstaller to build native C/C++
packages, both for Ruby and gems. DevKit is built and maintained by the
wonderful folks over at the RubyInstaller (http://rubyinstaller.org/) project.


### Ruby 1.8.7 on Windows

RubyInstaller is a self contained package installer which installs Ruby and
RubyGems on a windows system, head over to http://rubyinstaller.org/ for more
information.

### Packaging/Installer

We are using [Inno Setup](http://www.jrsoftware.org/isinfo.php "Inno Setup"),
a free installer for Windows programs.
