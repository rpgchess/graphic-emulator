library Fire {.rom};

{$E rom}

uses
  Windows, Screen, Utils in '..\Utils.pas';

const
  RomWidth = 320;
  RomHeight = 200;
  BtnStart: Boolean = False;

  RootRand = 20;
  Decay    = 4;
  Smooth   = 2;
  MinFire  = 50;

  XStart    = 5;
  XEnd      = RomWidth - 10;
  YStart    = 10;
  FireWidth = XEnd - XStart;
  FireAbility : Byte = 3;
  MoreFire    : Integer = 3;

var
  Seed     : array [XStart..XEnd] of Byte;
  Palette  : array [Byte] of TColorRef;
  Display  : TScreen;

function Rand(R: Integer): Integer;
begin
  Result := Random(R*2+1)-R;
end;

function Color2Index(Cor: TColorRef): Byte;
var
  i : Byte;
begin
  for i := 0 to 255 do
    if Palette[i] = Cor then begin
      Result := i;
      Break;
    end;
end;

function Hsi2Rgb(H, S, I: Real): TColorRef;
var
  T: Real;
  Cor: TColorRef;
  Rv,Gv,Bv: Real;
begin
  T := H;
  Rv := 1 + S * Sin(T - 2 * Pi / 3);
  Gv := 1 + S * Sin(T);
  Bv := 1 + S * Sin(T + 2 * Pi / 3);
  T := 63.999 * I / 2;
  Cor := RGB(Trunc(Rv*T),Trunc(Gv*T),Trunc(Bv*T));
  Result := Cor;
end;

procedure CreatePalette;
const
  MaxColor = 110;
var
  i     : Byte;
  R,G,B : Byte;
begin
  for i := 0 to MaxColor do
    Palette[i] := Hsi2Rgb(4.6-1.5*i/MaxColor,i/MaxColor,1.1*i/MaxColor);
  for i := MaxColor to 255 do begin
    Palette[i] := Palette[i-1];
    R := GetRValue(Palette[i]);
    G := GetGValue(Palette[i]);
    B := GetBValue(Palette[i]);
    if R < 63 then Inc(R);
    if R < 63 then Inc(R);
    if (i mod 2 = 0) and (G < 53) then Inc(G);
    if (i mod 2 = 0) and (B < 63) then Inc(B);
    Palette[i] := RGB(R,G,B);
  end;
end;

procedure Keyboard(Keys: TActionKeys); stdcall;
var
  i : Integer;
begin
  if (Up in Keys) or (Right in Keys) then
    if MoreFire < 4 then
      Inc(MoreFire);

  if (Down in Keys) or (Left in Keys) then
    if MoreFire > -2 then
      Dec(MoreFire);

  if Start in Keys then 
    BtnStart := not(BtnStart);

  if BtnA in Keys then
    FillChar(Seed,SizeOf(Seed),0);

  if BtnB in Keys then
    for i := 1 to 50 do
      Seed[XStart+Random(FireWidth)] := 0;

  if BtnC in Keys then begin end;
    FireAbility := 3 + Sqr(Random(9));
end;

procedure Start; stdcall;
var
  i : Integer;
begin
  Display := TScreen.Create(0,RomWidth,RomHeight);
  CreatePalette;
  Randomize;

  for i := XStart to XEnd do
    Seed[i] := 0;
end;

procedure Finish; stdcall;
begin
  Display.Destroy;
end;

function Loop: hDC; stdcall;
var
  iCor: Byte;
  i,j: Integer;
  X,Y: Integer;
begin
  with Display do begin
    if not(BtnStart) then begin
      for X := XStart to XEnd do begin
        SetPixel(X,RomHeight-1,Palette[Seed[X]]);
        for Y := YStart to RomHeight-1 do begin
          iCor := Color2Index(GetPixel(X,Y));
          if (iCor = 0) or (iCor < Decay) or (X <= XStart) or (X >= XEnd) then
            SetPixel(X,Pred(Y),Palette[0])
          else
            SetPixel(X-Pred(Random(3)),Pred(Y),Palette[iCor-Random(Decay)]);
        end;
      end;
      FillChar(Seed[XStart+Random(XEnd-XStart-5)],5,$FF);
      for i := XStart to XEnd do begin
        iCor := Seed[i];
        if iCor < MinFire then begin
          if iCor > 10 then
            Inc(iCor,Random(FireAbility));
        end else
          Inc(iCor,Rand(RootRand) + MoreFire);
        if iCor > 255 then
          iCor := 255;
        Seed[i] := iCor;
      end;
      for i := 1 to FireWidth div 8 do begin
        X := Trunc(Sqr(Random)*FireWidth/8);
        Seed[XStart+X] := 10;
        Seed[XEnd-X] := 10;
      end;
      for i := XStart+Smooth to XEnd-Smooth do begin
        X := 0;
        for j := -Smooth to Smooth do
          Inc(X,Seed[i+j]);
        Seed[i] := X div (2*Smooth+1);
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