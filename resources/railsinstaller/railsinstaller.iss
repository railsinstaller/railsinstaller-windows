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
;                         /dRubyPath=Ruby/1.9.2
;                         [/dInstVersion=26-OCT-2009]

; Full example:
; iscc resouces\railsinstaller\railsinstaller.iss \
;       /dInstallerVersion=2.1.0 \
;       /dStagePath=stage \
;       /dRubyPath=Ruby1.9.2 \
;       /opkg
;       /frailsinstaller-2.1.0.exe

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
Name: "en"; MessagesFile: "compiler:Default.isl,Default.isl"; LicenseFile: "LICENSE.txt"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl,Languages\BrazilianPortuguese.isl"; LicenseFile: "LICENSE-BR.txt"

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: {#StagePath}\{#RubyPath}\*; DestDir: {app}\{#RubyPath}; Excludes: "devkit.*, operating_system.*"; Flags: recursesubdirs createallsubdirs
Source: {#StagePath}\Git\*; DestDir: {app}\Git; Check: InstallGit; Flags: recursesubdirs createallsubdirs
Source: {#StagePath}\DevKit\*; DestDir: {app}\DevKit; Excludes: "config.yml"; Flags: recursesubdirs createallsubdirs
Source: {#StagePath}\DevKit\config.yml; DestDir: {app}\DevKit; AfterInstall: UpdateDevKitConfig('{app}\{#RubyPath}', '{app}\DevKit\config.yml')
Source: {#StagePath}\Sites\*; DestDir: {sd}\Sites; Flags: recursesubdirs createallsubdirs
Source: {#StagePath}\scripts\*; DestDir: {app}\scripts; Flags: recursesubdirs createallsubdirs
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
Name: {group}\{cm:IrbIconName}; Filename: {app}\{#RubyPath}\bin\irb.bat; WorkingDir: {app}\{#RubyPath}; IconFilename: {app}\{#RubyPath}\bin\ruby.exe; Flags: createonlyiffileexists
Name: {group}\{cm:RubyGemsDocIconName}; Filename: {app}\{#RubyPath}\bin\gem.bat; Parameters: server; IconFilename: {app}\{#RubyPath}\bin\ruby.exe; Flags: createonlyiffileexists runminimized
Name: {group}\{cm:CmdWithRailsIconName}; Filename: {sys}\cmd.exe; Parameters: /E:ON /K {app}\{#RubyPath}\setup_environment.bat {app}; WorkingDir: {sd}\Sites; IconFilename: {sys}\cmd.exe; Flags: createonlyiffileexists
Name: {group}\{cm:GitBashIconName}; Filename: {sys}\cmd.exe; Parameters: "/c """"{app}\Git\bin\sh.exe"" --login -i"""; WorkingDir: {sd}\Sites; IconFilename: {app}\Git\etc\git.ico; Check: InstallGit; Flags: createonlyiffileexists
; {%HOMEPATH%}
Name: {group}\{cm:UninstallProgram,{#InstallerName}}; Filename: {uninstallexe}

[Run]
Filename: "{app}\{#RubyPath}\bin\ruby.exe"; Parameters: "dk.rb install --force"; WorkingDir: "{app}\DevKit"; Flags: runhidden
Filename: {sys}\cmd.exe; Parameters: /E:ON /K {app}\{#RubyPath}\setup_environment.bat {app}; WorkingDir: {sd}\Sites; Description: "{cm:ConfigureGitCheckBoxDescription}"; Check: InstallGit; Flags: postinstall nowait skipifsilent

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
      Log(Format(CustomMessage('SelectedTasksLog'), [PathChkBox.State]));

      if IsModifyPath then
        ModifyPath([ExpandConstant('{app}') + '\{#RubyPath}\bin']);
  		if InstallGit then
  			ModifyPath([ExpandConstant('{app}') + '\Git\cmd']);

    end else
      MsgBox(CustomMessage('OlderWindowsVersionMsg'), mbInformation, MB_OK);
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  {* store install choices so we can use during uninstall *}
  if IsModifyPath then
    SetPreviousData(PreviousDataKey, 'PathModified', 'yes');
  if InstallGit then
	SetPreviousData(PreviousDataKey, 'GitInstalled', 'yes');

  SetPreviousData(PreviousDataKey, 'RailsInstallerId', '{#InstallerVersion}');
end;

procedure CurUninstallStepChanged(const CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if UsingWinNT then
    begin
      if GetPreviousData('PathModified', 'no') = 'yes' then
	    begin
        ModifyPath([ExpandConstant('{app}') + '\{#RubyPath}\bin']);
	    if GetPreviousData('GitInstalled', 'no') = 'yes' then
		  ModifyPath([ExpandConstant('{app}') + '\Git\cmd']);
		end
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
