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
#define InstallerName "RailsInstaller " + InstallerVersion
#define InstallerPublisher "RailsInstaller Team"
#define InstallerHomepage "http://www.railsinstaller.org"

#define CurrentYear GetDateTimeString('yyyy', '', '')

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications!
AppId={{613C3EA5-1248-4E35-B61A-6D0B31BBC0DB}
AppName={#InstallerName}
AppVerName={#InstallerName}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerHomepage}
AppVersion={#InstallerVersion}
DefaultGroupName={#InstallerName}
DefaultDirName={sd}\RailsInstaller
DisableProgramGroupPage=true
LicenseFile=LICENSE
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
WizardImageFile=compiler:wizmodernimage-is.bmp
WizardSmallImageFile=compiler:wizmodernsmallimage-is.bmp
PrivilegesRequired=lowest
ChangesAssociations=yes
ChangesEnvironment=yes

#if Defined(SignPackage) == 1
SignTool=risigntool sign /a /d $q{#InstallerName}$q /du $q{#InstallerHomepage}$q /t $qhttp://timestamp.comodoca.com/authenticode$q $f
#endif

[Languages]
Name: en; MessagesFile: compiler:Default.isl

[Messages]
en.WelcomeLabel1=Welcome to the [name] Installer
en.WelcomeLabel2=This will install [name/ver] on your computer. Please close all other applications before continuing.
en.WizardLicense={#InstallerName} License Agreement
en.LicenseLabel=
en.LicenseLabel3=Please read the following License Agreement and accept the terms before continuing the installation.
en.LicenseAccepted=I &accept the License
en.LicenseNotAccepted=I &decline the License
en.WizardSelectDir=Installation Destination and Optional Tasks
en.SelectDirDesc=
en.SelectDirLabel3=Setup will install [name] into the following folder. Click Install to continue or click Browse to use a different one.
en.SelectDirBrowseLabel=Please avoid any folder name that contains spaces (e.g. Program Files).
en.DiskSpaceMBLabel=Required free disk space: ~[mb] MB

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: ..\..\{#StagePath}\{#RubyPath}\*; DestDir: {app}\{#RubyPath}; Flags: recursesubdirs createallsubdirs
Source: ..\..\{#StagePath}\Git\*; DestDir: {app}\Git; Flags: recursesubdirs createallsubdirs
Source: ..\..\{#StagePath}\DevKit\*; DestDir: {app}\DevKit; Flags: recursesubdirs createallsubdirs
Source: setvars.bat; DestDir: {app}

[Registry]
; RubyInstaller identification for admin
; FIXME: Proper registry keys for RailsInstaller (admin)
;Root: HKLM; Subkey: Software\RailsInstaller; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsAdmin

; RubyInstaller identification for non-admin
; FIXME: Proper registry key for RailsInstaller (user)
;Root: HKCU; Subkey: Software\RailsInstaller; ValueType: string; ValueName: ; ValueData: ; Flags: uninsdeletevalue uninsdeletekeyifempty; Check: IsNotAdmin

[Icons]
Name: {group}\Interactive Ruby; Filename: {app}\{#RubyPath}\bin\irb.bat; IconFilename: {app}\{#RubyPath}\bin\ruby.exe; Flags: createonlyiffileexists
Name: {group}\RubyGems Documentation Server; Filename: {app}\{#RubyPath}\bin\gem.bat; Parameters: server; IconFilename: {app}\{#RubyPath}\bin\ruby.exe; Flags: createonlyiffileexists runminimized
Name: {group}\Start Command Prompt with RailsInstaller; Filename: {sys}\cmd.exe; Parameters: /E:ON /K {app}\setvars.bat; WorkingDir: {%HOMEDRIVE}{%HOMEPATH}; IconFilename: {sys}\cmd.exe; Flags: createonlyiffileexists
Name: {group}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}

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
