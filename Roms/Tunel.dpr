library Tunel {.rom};

{$E rom}

uses
  Windows, Screen, Utils in '..\Utils.pas';

const
  RomWidth = 320;
  RomHeight = 200;
  QtdPixel  = 90;
  QtdCircle = 25;

var
  Display: TScreen;

var
  PtsX,PtsY : array [1..QtdPixel,1..QtdCircle] of Integer;
  Circles   : array [1..360,1..QtdCircle] of Word;
  Palette   : array [Byte] of TColorRef;
  SinX,SinY : array [1..720] of Real;
  XX,YY     : Integer;
  PSin      : Integer;
  R         : Real;

procedure CreatePalette;
var
  i: Byte;
begin
  for i := 0 to 255 do
    Palette[i] := RGB(i,i,i);
end;

procedure Start; stdcall;
var
  i,j : Integer;
begin
  Display := TScreen.Create(0,RomWidth,RomHeight);
  CreatePalette;
  for i := 1 to QtdCircle do begin
    R := 0;
    for j := 1 to 360 do begin
      R := R + (0.0175)*4;
      Circles[j,i] := Round(Sin(R)*(5+(i shl 2))) + (5+(i shl 2));
    end;
  end;
  R := 0;
  for i := 1 to 720 do begin
    R := R + (0.0175)*4;
    SinX[i] := Round(Sin(R)*140) + 140;
    SinY[i] := Round(Cos(R)*QtdPixel) + QtdPixel;
  end;
  PSin := 0;
end;

procedure Finish; stdcall;
begin
  Display.Destroy;
end;

function Loop: hDC; stdcall;
var
  i,j : Byte;
  X,Y : Word;
begin
  with Display do begin
    if PSin > 178 then PSin := 0;
      Inc(PSin);
    for Y := 0 to RomHeight do
      for X := 0 to RomWidth do begin
        SetPixel(X,Y,Palette[0]);
        SetPixel(X,Y,Palette[0]);
        SetPixel(X,Y,Palette[0]);
      end;
    for i := 1 to QtdCircle do
      for j := 1 to QtdPixel do begin
        XX := PtsX[j,i];
        YY := PtsY[j,i];
        SetPixel(XX,YY,Palette[0]);
        XX := Round((Circles[j,i] + SinX[(i shl 1) + PSin]) - i*4);
        YY := Round((Circles[j+23,i] + SinY[PSin + QtdPixel + i]) - i*4);
        if ((XX > 0) and (XX < RomWidth)) then
          if ((YY > 0) and (YY < RomHeight)) then begin
            SetPixel(XX,YY,Palette[i*8]);
            PtsX[j,i] := XX;
            PtsY[j,i] := YY;
          end;
       end;
    Result := ScreenDC;
  end;
end;

exports
  Loop,
  Start,
  Finish;

begin
end.