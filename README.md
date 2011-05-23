# RailsInstaller

Rails development environment installer for Windows

## Overview

The goal of this project is to generate an installer that when run installs all
of the most common components for a Rails development environment with no
required prerequisites on a Windows system.

## How to Contribute

RailsInstaller is bootstrapped, built and packaged via rake tasks.

1. Download and install the [latest RailsInstaller](http://railsinstaller.org/)
1. Clone the project

    > git clone https://github.com/railsinstaller/railsinstaller-windows.git

    > cd railsinstaller-windows

1. Bootstrap the project, from the project root run

    > rake bootstrap

1. Install latest
   [Inno Setup Quick Start Pack](http://www.jrsoftware.org/isdl.php#qsp),
   ensure iscc.exe is in your PATH
1. Hackety hack!!! Type it like you mean it!!!
   Meaning implement your feature in the railsinstaller project code.
1. Download and build all components on the stage

    > rake build

1. Use Inno Setup to package RailsInstaller

    > rake package

1. Use the generated RailsInstaller.exe, be happy and prosperous!
   Be sure to share it with all of your friends!

### Configuration

Configuration of the packages are to be included is done in the
config/railsinstaller.yml file.

### Building

Building of the installer into the stage path for packaging happens from
the Ruby code in the lib/ directory, starting from the file

    lib/railsinstaller/actions.rb

Methods are implemented in

    lib/railsinstaller/methods.rb

In order to kick off a build into staging run the following rake command.

    > rake build

### Packaging

Packaging of the installer from the stage path into an executable can be done
via the following rake command.

    > rake package

### Development Kit (DevKit)

A MSYS/MinGW based toolkit that enables RailsInstaller to build native C/C++
packages, both for Ruby and gems. DevKit is built and maintained by the
wonderful folks over at the RubyInstaller (http://rubyinstaller.org/) project.


### Ruby 1.8.7/1.9.2 on Windows

RubyInstaller is a self contained package installer which installs Ruby and
RubyGems on a windows system, head over to http://rubyinstaller.org/ for more
information.

### Packaging/Installer

We are using [Inno Setup](http://www.jrsoftware.org/isinfo.php "Inno Setup"),
a free installer for Windows programs.

