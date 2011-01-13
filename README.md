# RailsInstaller

Rails development environment installer for Windows

## Overview

The goal of this project is to generate an installer that when run installs all
of the most common components for a Rails development environment with no
required prerequisites on a Windows system.

## How to Contribute

The entry point to the system is via Rake.

1. Download and install Install the Development Kit [DevKit]

2. Download and Install Ruby 1.8.7

   (1.8.7 recommended for maximum compatibility at this time)


2 3/16. [[ hackety hack... ]]


3. Use DevKit to build all components on the stage

  > rake railsinstaller:build

4. Install require gems:

  > gem install rubyzip2 rake rails

5. Install latest Inno Setup Quick Start Pack, ensure iscc.exe is in your PATH

   http://www.jrsoftware.org/isdl.php#qsp

6. Use Inno Setup to package RailsInstaller

  > rake railsinstaller:package

7. Use the generated RailsInstaller.exe and be happy!

### Development Kit (DevKit)

A MSYS/MinGW based toolkit that enables RailsInstaller to build native C/C++
packages, both for Ruby and gems. DevKit is built and maintained by the
wonderful folks over at the RubyInstaller (http://rubyinstaller.org/) project.


### Ruby 1.8.7 on Windows

RubyInstaller is a self contained package installer which installs Ruby and
RubyGems on a windows system, head over to http://rubyinstaller.org/ for more
information.

### Packaging/Installer

We are using [Inno Setup](http://www.jrsoftware.org/isinfo.php "Inno Setup"), a free installer for Windows programs.
