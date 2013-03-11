# RailsInstaller

Rails development environment installer for Windows.

## Overview

The goal of this project is to generate an installer that when run installs all
of the most common components for a Rails development environment with no
required prerequisites on a Windows system.

## How to Contribute

RailsInstaller project code repository is located on GitHub and is bootstrapped,
built and packaged via rake tasks.

1. Download and install the latest
   [RailsInstaller](http://railsinstaller.org/).

1. Download and install latest
   [Inno Setup Quick Start Pack](http://www.jrsoftware.org/isdl.php#qsp),
   add iscc.exe is in your PATH

1. [Fork](http://help.github.com/fork-a-repo/)
   the [RailsInstaller project on github](https://github.com/railsinstaller/railsinstaller-windows.git)
   into your own github account.

1. Open the the command prompt from the start menu and change directory to where you like to keep your projects.

1. Clone your fork of the project.

    > git clone git@github.com:{{your github user name}}/railsinstaller-windows

    > cd railsinstaller-windows

1. Update from origin master (or 2.0.0) branch and checkout a new topic branch for your feature/bugfix.

    > git checkout master

    > git pull origin master

    > git checkout -b mybranchname

1. Bootstrap the project. From the project root run:

    > rake bootstrap

1. Implement your new feature and/or fix your bug in your newly forked Railsinstaller project code.

  * The configuration file for specifying required packages can be found at config/railsinstaller.yml.

  * Building of the installer into the stage path for packaging is implemented by Ruby code in the lib/ directory, starting with the file lib/railsinstaller/actions.rb.

  * Methods called by the actions.rb file are implemented by lib/railsinstaller/methods.rb.

1. Next build all components onto the stage (into the stage/ directory)

    > rake build

1. Use Inno Setup to package the installer into an executable (.exe) for testing/distribution.

    > rake package

  * This creates the executable (.exe) package file in the pkg/ directory from the files staged during the build process in the stage/ directory.
			
  * NOTE - You can run the package task with --trace for debugging output if the package fails to build or if you simply want to see what is being done as it is done).

1. Once you have verified your new feature/bug-fix, push your branch up to GitHub.

    > git commit -a -m "Implemented featureX/bugfixX which <description>..."

    > git push origin mybranchname

1. Now issue a [pull request](http://help.github.com/pull-requests/) on GitHub.

# RailsInstaller Components

The next few sections detail the core components that make up RailsInstaller.

### Ruby 1.9.3 on Windows

RubyInstaller is a self contained package installer which installs Ruby and RubyGems on a windows system, head over to [http://rubyinstaller.org/](http://rubyinstaller.org/) for more information.

### Development Kit (DevKit)

A MSYS/MinGW based toolkit that enables RailsInstaller to build native C/C++ packages, both for Ruby and gems. DevKit is built and maintained by the wonderful folks over at the RubyInstaller project.

### Git

The git version that is bundled into RailsInstaller is
[msysgit](http://code.google.com/p/msysgit/).

### Packaging/Installer

We are using [Inno Setup](http://www.jrsoftware.org/isinfo.php "Inno Setup"), a free installer for Windows programs.