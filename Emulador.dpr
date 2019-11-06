program Emulador;

uses
  Windows, Messages, Utils;

{$R Resource.res}
{$I Resource.inc}

const
  RomWidth = 320;
  RomHeight = 200;
  SAppName  = 'WinEmu';
  SAppTitle = 'Emulador';
  Width: Integer = 320;
  Height: Integer = 200;
  Mode13: Boolean = True;
  OldMode13: Boolean = True;
  Maximized: Boolean = False;

var
  AppInstance : LongWord;
  AppActived  : Boolean;
  AppName     : PChar;
  FormDC      : hDC;
  // Rom Variables
  LoadRom : Boolean;
  Rom     : TRomFile;
  ActionKeys: TActionKeys;

{$I Dialogs.inc}
{$I Keyboard.inc}

procedure DrawRom;
begin
  if Mode13 then
    BitBlt(FormDC,0,0,Width,Height,Rom.OnLoop,0,0,SRCCOPY)
  else
    StretchBlt(FormDC,0,0,Width,Height,Rom.OnLoop,0,0,RomWidth,RomHeight,SRCCOPY);
end;

procedure DisplayMode(Display: hWnd; Mode: TDisplayMode);
begin
  SendMessage(Display,WM_SYSCOMMAND,SC_RESTORE,MakeLParam(0,0));
  case Mode of
  Mode320x200: begin Mode13 := True; SizeClient(Display,320,200); end;
  Mode640x480: begin Mode13 := False; SizeClient(Display,640,480); end;
  Mode800x600: begin Mode13 := False; SizeClient(Display,800,600); end;
  end;
  CenterWindow(Display);
end;

function WindowProc(Wnd, iMsg, wParam, lParam: LongWord): LResult; stdcall;
var
  R: TRect;
begin
  case iMsg of
  WM_CREATE: begin
    Rom.Handle := 0;
    LoadRom := False;
    AppActived := True;
    FormDC := GetDC(Wnd);
    SizeClient(Wnd,Width,Height);
    CenterWindow(Wnd);    
  end;
  WM_CLOSE: begin
    if CloseRom(Rom) then
      LoadRom := False;
    ReleaseDC(Wnd,FormDC);
    DestroyWindow(Wnd);
  end;
  WM_DESTROY: begin
    UnRegisterClass(AppName,AppInstance);
    PostQuitMessage(0);
  end;
  WM_SYSCOMMAND: begin
    case wParam of
    SC_MAXIMIZE: begin OldMode13 := Mode13; Mode13 := False; end;
    SC_RESTORE: Mode13 := OldMode13;
    end;
    Result := DefWindowProc(Wnd,iMsg,wParam,lParam);
  end;
  WM_COMMAND:
    case LoWord(wParam) of
    ID_EXIT: SendMessage(Wnd,WM_CLOSE,0,0);
    ID_ABOUT: DialogBox(AppInstance,'DlgAbout',Wnd,@DlgAbout);
    ID_KEYBOARD: DialogBox(AppInstance,'DlgKeyboard',Wnd,@DlgKeyboard);
    ID_320x200: DisplayMode(Wnd,Mode320x200);
    ID_640x480: DisplayMode(Wnd,Mode640x480);
    ID_800x600: DisplayMode(Wnd,Mode800x600);
    ID_CLOSE:
      if CloseRom(Rom) then begin
        LoadRom := False;
        GetClientRect(Wnd,R);
        SetWindowText(Wnd,PChar(SAppTitle));
        FillRect(FormDC,R,GetStockObject(BLACK_BRUSH));
      end;
    ID_OPEN: begin
      LoadRom := OpenRom(Wnd,Rom);
      SetWindowText(Wnd,PChar(SAppTitle +' - '+ Rom.FileName));
    end;
    else
      Result := DefWindowProc(Wnd,iMsg,wParam,lParam);
    end;
  WM_ACTIVATE: if LoWord(wParam) = WA_INACTIVE then AppActived := False else AppActived := True;
  WM_SIZE: begin Height := HiWord(lParam); Width := LoWord(lParam); end;
  WM_KEYDOWN: FilterKeyboard(wParam);
  else
    Result := DefWindowProc(Wnd,iMsg,wParam,lParam);
  end;
end;

function WindowMain(hInst, hPrevInst: LongWord; sCmdLine: PChar; iCmdShow: Integer): Integer;
var
  WndClass : TWndClassEx;
  Form     : hWnd;
  Msg      : TMsg;
begin
  AppName := PChar(SAppName);

  if not(GetClassInfoEx(0,AppName,WndClass)) then begin
    with WndClass do begin
      cbSize        := SizeOf(TWndClassEx);
      style         := CS_HREDRAW or CS_VREDRAW or CS_CLASSDC or CS_DBLCLKS;
      lpfnWndProc   := @WindowProc;
      cbClsExtra    := 0;
      cbWndExtra    := 0;
      hInstance     := hInst;
      hIcon         := LoadIcon(hInst,'MainIcon');
      hIconSm       := LoadIcon(hInst,'MainIcon');
      hCursor       := LoadCursor(0,IDC_ARROW);
      hbrBackground := GetStockObject(BLACK_BRUSH);
      lpszMenuName  := 'MainMenu';
      lpszClassName := AppName;
    end;
    RegisterClassEx(WndClass);
  end;
  Form := CreateWindowEx(0,AppName,PChar(SAppTitle),WS_OVERLAPPEDWINDOW and not WS_THICKFRAME,0,0,Width,Height,0,0,hInst,nil);

  ShowWindow(Form,iCmdShow);
  UpdateWindow(Form);

  while True do begin
    if PeekMessage(Msg,0,0,0,PM_REMOVE) then begin
      if Msg.message = WM_QUIT then Break;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end else
      if AppActived then
        if LoadRom then
          DrawRom;
  end;

  Halt(Msg.wParam);
end;

begin
  AppInstance := hInstance;
  WindowMain(AppInstance,0,GetCommandLine,SW_SHOWDEFAULT);
  ExitProcess(0);
end.