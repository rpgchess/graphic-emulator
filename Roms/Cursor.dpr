library Cursor {.rom};

{$E rom}

uses
  Windows, Screen, Utils in '..\Utils.pas';

{$R Cursor\Cursor.res}

type
  TMouseOption = (Slow,Medio,Fast);

const
  RomWidth = 320;
  RomHeight = 200;
  MouseWidth = 8;
  MouseHeight = 14;
  MouseSpeed : Byte = 5;
  BtnStart   : Boolean = False;
  Mouse      : TPoint = (x:0;y:0);

var
  Display: TScreen;
  CursorMask: hBitmap;
  CursorDef: hBitmap;

procedure MouseOption(Option: TMouseOption);
begin
  case Option of
  Slow : MouseSpeed := 2;
  Medio: MouseSpeed := 5;
  Fast : MouseSpeed := 10;
  end;
end;

procedure EraseCursor(DC: hDC);
var
  R: TRect;
begin
  with R do begin
    Left := Mouse.x;
    Top := Mouse.y;
    Right := Left + MouseWidth;
    Bottom := Top + MouseHeight;
    FillRect(DC,R,GetStockObject(BLACK_BRUSH));
  end;
end;

procedure DrawCursor(DC: hDC);
var
  TempDC: hDC;
begin
  with Mouse do begin
    if (y < 0) or (y > 200) and (x < 0) or (x > 320) then Exit;
    TempDC := CreateCompatibleDC(DC);
    SelectObject(TempDC, CursorMask);
    BitBlt(DC,x,y,MouseWidth,MouseHeight,TempDC,0,0,SRCAND);
    SelectObject(TempDC, CursorDef);
    BitBlt(DC,x,y,MouseWidth,MouseHeight,TempDC,0,0,SRCPAINT);
    DeleteDC(TempDC);
  end;
end;

procedure Keyboard(Keys: TActionKeys); stdcall;
begin
  with Mouse do begin
    EraseCursor(Display.ScreenDC);
    if Up in Keys then Dec(y,MouseSpeed);
    if Down in Keys then Inc(y,MouseSpeed);
    DrawCursor(Display.ScreenDC);
    EraseCursor(Display.ScreenDC);
    if Left in Keys then Dec(x,MouseSpeed);
    if Right in Keys then Inc(x,MouseSpeed);
    DrawCursor(Display.ScreenDC);
  end;

  if Start in Keys then
    BtnStart := not(BtnStart);

  if BtnA in Keys then
    MouseOption(Slow);
  if BtnB in Keys then
    MouseOption(Medio);
  if BtnC in Keys then
    MouseOption(Fast);
end;

procedure Start; stdcall;
begin
  Display := TScreen.Create(0,RomWidth,RomHeight);
  CursorMask := LoadBitmap(hInstance,'MCursor');
  CursorDef := LoadBitmap(hInstance,'Cursor');
  DrawCursor(Display.ScreenDC);
end;

procedure Finish; stdcall;
begin
  DeleteObject(CursorMask);
  DeleteObject(CursorDef);
  Display.Destroy;  
end;

function Loop: hDC; stdcall;
begin
  with Display do begin
    if not(BtnStart) then begin

    end;
    Result := ScreenDC;
  end;
end;

exports
  Loop,
  Start,
  Finish,
  Keyboard;

begin
end.