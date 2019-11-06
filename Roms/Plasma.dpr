library Plasma {.rom};

{$E rom}

uses
  Windows, Screen, Utils in '..\Utils.pas';

const
  RomWidth = 320;
  RomHeight = 200;
  ModePlasma: Byte = 8;
  BtnStart: Boolean = False;

var
  Palette : array [Byte] of TColorRef;
  Display: TScreen;

procedure CreatePalette;
var
  i : Byte;
begin
  for  i := 0 to (256 div 2) do begin
    Palette[i] := RGB(i,i,i);
    Palette[255-i] := Palette[i];
  end;
end;

procedure RotatePalette;
var
  i   : Byte;
  Cor : TColorRef;
begin
  Cor := Palette[0];
  for i := 1 to 255 do
    Palette[i-1] := Palette[i];
  Palette[255] := Cor;
end;

function XYPlasma(Mode: Byte; X,Y,Wid,Heig: Integer): Byte;
begin
  case Mode of
  0: Result := Round(Sin(X*X  /Wid/30)*440 + Cos(X*Y  /Heig/50)*200);
  1: Result := Round(Sin(X*X  /Wid/30)*440 + Cos(Y*150/Heig/14)*60);
  2: Result := Round(Sin(X*100/Wid/14)*60  + Cos(Y*100/Heig/14)*60);
  3: Result := Round(Sin(X*Y  /Wid/20)*280 + Cos(Y*120/Heig/14)*160);
  4: Result := Round(Sin(X*Y  /Wid/40)*235 + Cos(Y*120/Heig/14)*160);
  5: Result := Round(Sin(X*50 /Wid/30)*440 + Cos(X*Y  /Heig/50)*160);
  6: Result := Round(Sin(X*Y  /Wid/60)*240 + Cos(X*Y  /Heig/14)*200);
  7: Result := Round(Sin(X*X  /Wid/30)*440 + Cos(X*120/Heig/50)*160);
  8: Result := Round(Sin(X*10 /Wid/60)*240 + Cos(X*Y  /Heig/14)*200);
  9: Result := Round(Sin(X*X  /Wid/30)*280 + Cos(X*Y  /Heig/50)*460);
  end;
end;

procedure Keyboard(Keys: TActionKeys); stdcall;
begin
  if (Up in Keys) or (Right in Keys) then
    if ModePlasma < 9 then
      Inc(ModePlasma,1);

  if (Down in Keys) or (Left in Keys) then
    if ModePlasma > 0 then
      Dec(ModePlasma,1);

  if Start in Keys then
    BtnStart := not(BtnStart);
end;

procedure Start; stdcall;
begin
  Display := TScreen.Create(0,RomWidth,RomHeight);
  CreatePalette;
end;

procedure Finish; stdcall;
begin
  Display.Destroy;
end;

function Loop: hDC; stdcall;
var
  X,Y: Word;
begin
  with Display do begin
    if not(BtnStart) then begin
      RotatePalette;
      for Y := 0 to GetHeight do
        for X := 0 to GetWidth do
          SetPixel(X,Y,Palette[XYPlasma(ModePlasma,X,Y,GetWidth,GetHeight)]);
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