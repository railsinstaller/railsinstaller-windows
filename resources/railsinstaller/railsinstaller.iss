; RailsInstaller - InnoSetup Script
; Adaptation from RubyInstaller installer script
;

; PRE-CHECK
; Verify that RubyPath is defined by ISCC using
; /d command line arguments.
;
; Usage:
;  iscc rubyinstaller.iss /dInstallerVersion=0.1.0
;                         /dStagePath=stage
;                         /dRubyPath=Ruby/1.8.7
;                         [/dInstVersion=26-OCT-2009]

; Full example:
; iscc resouces\railsinstaller\railsinstaller.iss \
;       /dInstallerVersion=0.1.0 \
;       /dStagePath=stage \
;       /dRubyPath=Ruby1.8.7 \
;       /opkg
;       /frailsinstaller-0.1.0.exe

#if Defined(InstallerVersion) == 0
  #error Please provide a InstallerVersion definition using a /d parameter.
#endif

#if Defined(StagePath) == 0
  #error Please provide a StagePath value to the Ruby files using a /d parameter.
#endif

#if Defined(RubyPath) == 0
  #error Please provide a RubyPath value to the Ruby files using a /d parameter.
#else
  #if FileExists(StagePath + '/' + RubyPath + '\bin\ruby.exe') == 0
    #error No Ruby installation (bin\ruby.exe) found inside defined RubyPath. Please verify.
  #endif
#endif

#if Defined(InstVersion) == 0
  #define InstVersion GetDateTimeString('dd-mmm-yy"T"hhnn', '', '')
#endif

; Build Installer details using above values
#define InstallerName "RailsInstaller"
#define InstallerNameWithVersion InstallerName + " " + InstallerVersion
#define InstallerPublisher "RailsInstaller Team"
#define InstallerHomepage "http://www.railsinstaller.org/"

#define CurrentYear GetDateTimeString('yyyy', '', '')

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications!
AppId={{613C3EA5-1248-4E35-B61A-6D0B31BBC0DB}
AppName={#InstallerName}
AppVerName={#InstallerNameWithVersion}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerHomepage}
AppVersion={#InstallerVersion}
DefaultGroupName={#InstallerName}
DefaultDirName={sd}\RailsInstaller
DisableProgramGroupPage=true
LicenseFile=LICENSE.txt
Compression=lzma2/ultra64
SolidCompression=true
AlwaysShowComponentsList=false
DisableReadyPage=true
InternalCompressLevel=ultra64
VersionInfoCompany={#InstallerPublisher}
VersionInfoCopyright=(c) {#CurrentYear} {#InstallerPublisher}
VersionInfoDescription=Rails development environment installer for Windows
VersionInfoTextVersion={#InstallerVersion}
VersionInfoVersion={#InstallerVersion}
UninstallDisplayIcon={app}\bin\ruby.exe
WizardImageFile={#ResourcesPath}\images\RailsInstallerWizardImage.bmp
WizardSmallImageFile={#ResourcesPath}\images\RailsInstallerWizardImageSmall.bmp
PrivilegesRequired=lowest
ChangesAssociations=yes
ChangesEnvironment=yes

#if Defined(SignPackage) == 1
SignTool=risigntool sign /a /d $q{#InstallerNameWithVersion}$q /du $q{#InstallerHomepage}$q /t $qhttp://timestamp.comodoca.com/authenticode$q $f
#endif

[Languages]
Name: en; MessagesFile: compiler:Default.isl

[Messages]
en.InstallingLabel=Installing [name], this will take a few minutes...
en.WelcomeLabel1=Welcome to [name]!
en.WelcomeLabel2=This will install [name/ver] on your computer which includes Ruby 1.8.7, Git, Sqlite3, DevKit, and Rails 3.  Please close any console applications before continuing.
en.WizardLicense={#InstallerName} License Agreement
en.LicenseLabel=
en.LicenseLabel3=Please read the following License Agreements and accept the terms before continuing the installation.
en.LicenseAccepted=I &accept all of the Licenses
en.LicenseNotAccepted=I &decline any of the Licenses
en.WizardSelectDir=Installation Destination and Optional Tasks
en.SelectDirDesc=This is the location that Ruby, DevKit, Git, Rails and Sqlite will be installed to.
en.SelectDirLabel3=[name] will be installed into the following folder. Click Install to continue or click Browse to use a different one.
en.SelectDirBrowseLabel=Please avoid any folder name that contains spaces (e.g. Program Files).
en.DiskSpaceMBLabel=Required free disk space: ~[mb] MB

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: {#StagePath}\{#RubyPath}\*; DestDir: {app}\{#RubyPath}; Excludes: "devkit.*, operating_system.*"; Flags: recursesubdirs createallsubdirs
Source: {#StagePath}\Git\*; DestDir: {app}\Git; Flags: recursesubdirs createallsubdirs
Source: {#StagePath}\DevKit\*; DestDir: {app}\DevKit; Excludes: "config.yml"; Flags: recursesubdirs createallsubdirs
Source: {#StagePath}\DevKit\config.yml; DestDir: {app}\DevKit; AfterInstall: UpdateDevKitConfig('{app}\{#RubyPath}', '{app}\DevKit\config.yml')
Source: {#StagePath}\Sites\*; DestDir: %HOMEDRIVE%%HOMEPATH%\Sites; Flags: recursesubdirs createallsubdirs
; TODO: Instead of running the full vcredist, simply extract and bundle the dll
;       files with an associated manifest.
; Source: {#StagePath}\pkg\vcredist_x86.exe; DestDir: {tmp}; Flags: deleteafterinstall
Source: setup_environment.bat; DestDir: {app}\{#RubyPath}

[Registry]
; FIXME: Proper registry keys for RailsInstaller (admin)
;Root: HKLM; Subkey: Software\RailsInstaller; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsAdmin

; FIXME: Proper registry key for RailsInstaller (user)
;Root: HKCU; Subkey: Software\RailsInstaller; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsNotAdmin

[Icons]
Name: {group}\Interactive Ruby; Filename: {app}\{#RubyPath}\bin\irb.bat; WorkingDir: {app}\{#RubyPath} ; IconFilename: {app}\{#RubyPath}\bin\ruby.exe; Flags: createonlyiffileexists
Name: {group}\RubyGems Documentation Server; Filename: {app}\{#RubyPath}\bin\gem.bat; Parameters: server; IconFilename: {app}\{#RubyPath}\bin\ruby.exe; Flags: createonlyiffileexists runminimized
Name: {group}\Command Prompt with Ruby and Rails; Filename: {sys}\cmd.exe; Parameters: /E:ON /K {app}\{#RubyPath}\setup_environment.bat; WorkingDir: {sd}\Sites; IconFilename: {sys}\cmd.exe; Flags: createonlyiffileexists
; {%HOMEPATH%}
Name: {group}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}

[Run]
Filename: "{app}\{#RubyPath}\bin\ruby.exe"; Parameters: "dk.rb install --force"; WorkingDir: "{app}\DevKit"; Flags: runhidden
; TODO: Instead of running the full vcredist, simply extract and bundle the dll
;       files with an associated manifest.
; Filename: "{tmp}\vcredist_x86.exe"; StatusMsg: "Installing Microsoft Visual C++ 2008 SP1 Redistributable Package (x86)..." ; Parameters: "/q"; WorkingDir: "{tmp}"; Flags: runhidden

[Code]
#include "util.iss"
#include "railsinstaller_gui.iss"

function GetInstallDate(Param: String): String;
begin
  Result := GetDateTimeString('yyyymmdd', #0 , #0);
end;

procedure CurStepChanged(const CurStep: TSetupStep);
begin

  // TODO move into ssPostInstall just after install completes?
  if CurStep = ssInstall then
  begin
    if UsingWinNT then
    begin
      Log(Format('Selected Tasks - Path: %d', [PathChkBox.State]));

      if IsModifyPath then
        ModifyPath([ExpandConstant('{app}') + '\{#RubyPath}\bin']);
        ModifyPath([ExpandConstant('{app}') + '\Git\cmd']);

    end else
      MsgBox('Looks like you''ve got on older, unsupported Windows version.' #13 +
             'Proceeding with a reduced feature set installation.',
             mbInformation, MB_OK);
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  {* store install choices so we can use during uninstall *}
  if IsModifyPath then
    SetPreviousData(PreviousDataKey, 'PathModified', 'yes');

  SetPreviousData(PreviousDataKey, 'RailsInstallerId', '{#InstallerVersion}');
end;

procedure CurUninstallStepChanged(const CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if UsingWinNT then
    begin
      if GetPreviousData('PathModified', 'no') = 'yes' then
        ModifyPath([ExpandConstant('{app}') + '\{#RubyPath}\bin']);
        ModifyPath([ExpandConstant('{app}') + '\Git\cmd']);
    end;
  end;
end;

procedure UpdateDevKitConfig(RubyPath: string; FileName: string);
var
  S: String;
begin
  // Make YAML happy :-)
  S := ExpandConstant(RubyPath);
  StringChangeEx(S, '\', '/', True);

  // Update DevKit config.yml with the installation path
  SaveStringToFile(ExpandConstant(FileName), '- ' + S, False);
end;
