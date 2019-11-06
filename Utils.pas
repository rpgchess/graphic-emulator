unit Utils;

interface

uses
  Windows, CommDlg;

const
  MaxOpenFiles = 9;

type
  TFileName = array [0..MAX_PATH] of Char;
  TCommandFile = (Save,Open);

  TActionKeys = Set of (Up,Down,Left,Right,Start,BtnA,BtnB,BtnC);

  //------------------------------
  // Events of FileRom
  //------------------------------
  TLoopProc = function:hDC; stdcall;
  TRomProc = procedure; stdcall;
  TKeyboardProc = procedure(Keys: TActionKeys); stdcall;
  TDisplayMode = (Mode320x200,Mode640x480,Mode800x600);
  //------------------------------
  // Rom Struct
  //------------------------------
  TRomFile = record
    Handle: hWnd;
    FileName: TFileName;
    // Events
    OnLoop: TLoopProc;
    OnStart: TRomProc;
    OnFinish: TRomProc;
    OnKeyboard: TKeyboardProc;
  end;{
  //------------------------------
  // File Configurations
  //------------------------------
  TWindowPos = record
    Top    : Word;
    Left   : Word;
    Width  : Word;
    Height : Word;
  end;

  TControl = record
    Up    : Byte;
    Left  : Byte;
    Down  : Byte;
    Right : Byte;
    Start : Byte;
    BtnA  : Byte;
    BtnB  : Byte;
    BtnC  : Byte;
  end;

  TFolders = record
    PathRom : TFileName;
    PathScreenShot : TFileName;
    PathDocumentation : TFileName;
  end;

  TOpenFiles = record
    OpenFile: array [0..MaxOpenFiles] of TFileName;
  end;

  TConfigParams = record
    WindowPos : TWindowPos;
    KeyCtrls  : TControl;
    PathsApp  : TFolders;
    Files     : TOpenFiles;
  end;

  TFileConfig = File of TConfigParams;
}
  function CleanKeys(var Keys: TActionKeys): Boolean;

  procedure CenterWindow(Wnd: hWnd);
  procedure SizeClient(Wnd: hWnd; Wid,Heig: Integer);

  function OpenRom(Wnd: hWnd; var Rom: TRomFile): Boolean;
  function CloseRom(var Rom: TRomFile): Boolean;
{
  function OpenFileConfig(var Config: TConfigParams; FileName: String): Boolean;
  function SaveFileConfig(var Config: TConfigParams; FileName: String): Boolean;
}
implementation

function CleanKeys(var Keys: TActionKeys): Boolean;
begin
  if Up in Keys then Exclude(Keys,Up);
  if Down in Keys then Exclude(Keys,Down);
  if Left in Keys then Exclude(Keys,Left);
  if Right in Keys then Exclude(Keys,Right);
  if Start in Keys then Exclude(Keys,Start);
  if BtnA in Keys then Exclude(Keys,BtnA);
  if BtnB in Keys then Exclude(Keys,BtnB);
  if BtnC in Keys then Exclude(Keys,BtnC);
end;

function OpenDialog(Wnd: hWnd; var FileName: TFileName): Boolean;
var
  DlgOpen : TOpenFileName;
begin
  Result := False;
  FillChar(DlgOpen,SizeOf(DlgOpen),$00);
  with DlgOpen do begin
    lStructSize := SizeOf(DlgOpen);
    hWndOwner := Wnd;
    hInstance := hInstance;
    lpstrFilter := 'Roms (*.rom)'+ #0 +'*.rom'+ #0#0;
    lpstrFile := FileName;
    nMaxFile := SizeOf(FileName);
    lpstrInitialDir := '.';
    lpstrTitle := 'Abrir Rom:';
    lpstrFileTitle := '< Nome do Arquivo >';
    nMaxFileTitle := 0;
    Flags := OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY;
    if GetOpenFileName(DlgOpen) then
      Result := True;
  end;
end;

function GetRect(Wnd: hWnd): TRect;
var
  Style: LongWord;
  CmpStyle: LongWord;
begin
  Style := GetWindowLong(Wnd,GWL_STYLE);
  CmpStyle := Style and not WS_CAPTION;
  if CmpStyle <> Style then
    GetWindowRect(Wnd,Result)
  else
    GetClientRect(Wnd,Result);
end;

procedure SizeClient(Wnd: hWnd; Wid,Heig: Integer);
var
  R: TRect;
  Style: LongWord;
  CmpStyle: LongWord;
  NewWid : Integer;
  NewHeig : Integer;
begin
  Style := GetWindowLong(Wnd,GWL_STYLE);
  CmpStyle := Style and not WS_CAPTION;
  NewWid := Wid; NewHeig := Heig;  
  if CmpStyle <> Style then begin
    NewWid := Wid + (GetSystemMetrics(SM_CXDLGFRAME)* 2);
    NewHeig := Heig + GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYMENU) + 2;
  end;
  SetWindowPos(Wnd,HWND_TOP,0,0,NewWid,NewHeig,SWP_NOMOVE);
end;

procedure CenterWindow(Wnd: hWnd);
var
  R: TRect;
  Left,Top : Integer;
begin
  R := GetRect(Wnd);
  Left := (GetSystemMetrics(SM_CXSCREEN) - (R.Right - R.Left)) div 2;
  Top := (GetSystemMetrics(SM_CYSCREEN) - (R.Bottom - R.Top)) div 2;
  SetWindowPos(Wnd,HWND_TOP,Left,Top,0,0,SWP_NOSIZE);
end;
{
function CmdFileConfig(Cmd: TCommandFile; var Config: TConfigParams; FileName: String): Boolean;
var
  FTemp: TFileConfig;
begin
  Result := False;
  AssignFile(FTemp,FileName);
  case Cmd of
  Open: Reset(FTemp);
  Save: ReWrite(FTemp);
  end;
  if IOResult <> 0 then begin
    case Cmd of
    Open: Read(FTemp,Config);
    Save: Write(FTemp,Config);
    end;
    Result := True;
  end;
  CloseFile(FTemp);
end;

function OpenFileConfig(var Config: TConfigParams; FileName: String): Boolean;
begin
  Result := CmdFileConfig(Open,Config,FileName);
end;

function SaveFileConfig(var Config: TConfigParams; FileName: String): Boolean;
begin
  Result := CmdFileConfig(Save,Config,FileName);
end;
}
function OpenRom(Wnd: hWnd; var Rom: TRomFile): Boolean;
begin
  Result := False;
  with Rom do begin
    if OpenDialog(Wnd,FileName) then begin
      if Handle <> 0 then CloseRom(Rom);
      if Handle = 0 then begin
        Handle := LoadLibrary(FileName);
        if Handle <> 0 then begin
          @OnLoop := GetProcAddress(Handle,'Loop');
          @OnStart := GetProcAddress(Handle,'Start');
          @OnFinish := GetProcAddress(Handle,'Finish');
          @OnKeyboard := GetProcAddress(Handle,'Keyboard');
          if Assigned(OnStart) and Assigned(OnLoop) and Assigned(OnFinish) then begin
            Result := True;
            OnStart;
          end;
        end;
      end;
    end;
  end;
end;

function CloseRom(var Rom: TRomFile): Boolean;
begin
  Result := False;
  with Rom do
    if Handle <> 0 then begin
      OnFinish;
      if FreeLibrary(Handle) then begin
        OnLoop := nil;
        OnStart := nil;
        OnFinish := nil;
        OnKeyboard := nil;
        Result := True;
        Handle := 0;        
      end;
    end;
end;

end.