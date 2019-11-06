library TV {.rom};

{$E rom}

uses
  Windows, Screen, Utils in '..\Utils.pas';

const
  RomWidth = 320;
  RomHeight = 200;
  Command: Byte = 0;
  Intensity: Byte = 255;
  TVLigada: Boolean = True;
  BtnStart: Boolean = False;

var
  Display: TScreen;

procedure Keyboard(Keys: TActionKeys); stdcall;
begin
  if (Up in Keys) or (Right in Keys) then
    if Intensity < 255 then
      Inc(Intensity,1);

  if (Down in Keys) or (Left in Keys) then
    if Intensity > 0 then
      Dec(Intensity,1);

  if Start in Keys then
    BtnStart := not BtnStart;

  if BtnA in Keys then
    TVLigada := not(TVLigada);
end;

procedure Start; stdcall;
begin
  Display := TScreen.Create(0,RomWidth,RomHeight);
end;

procedure Finish; stdcall;
begin
  Display.Destroy;
end;

function Loop: hDC; stdcall;
var
  iCor: Byte;
  X,Y : Word;
begin
  with Display do begin
    if not(BtnStart) then begin
      if TVLigada then
        for Y := 0 to GetHeight do
          for X := 0 to GetWidth do begin
            iCor := Random(Intensity);
            SetPixel(X,Y,RGB(iCor,iCor,iCor));
          end;
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