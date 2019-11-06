unit Screen;

interface

uses
  Windows;

type
  TScreen = class
  private
    BmpInfo : TBitmapInfo;
    Width   : Integer;
    Height  : Integer;
    Bmp     : hBitmap;
  public
    ScreenDC : hDC;
    Bpp      : Byte;
    Surface  : Pointer;
    constructor Create(DC: hDC; Wid, Heig: Integer);
    destructor Destroy; override;

    function GetWidth: Integer;
    function GetHeight: Integer;
    function InBuffer(X, Y: Integer): Integer;
    function GetPixel(X, Y: Integer): TColorRef;
    procedure SetPixel(X, Y: Integer; Cor: TColorRef);
    procedure LineSlow(XStart, YStart, XEnd, YEnd: Integer; Cor: TColorRef);
    procedure LineFast(XStart, YStart, XEnd, YEnd: Integer; Cor: TColorRef);    
    procedure Rectangle(XStart, YStart, XEnd, YEnd: Integer; Cor: TColorRef);
    procedure Polyline(Vertices: array of TPoint; Cor: TColorRef);
    procedure Ellipse(X, Y, Raio: Integer; Cor: TColorRef);
    procedure Draw(DC: hDC; X, Y: Integer); overload;
    procedure Draw(DC: hDC; Left, Top, Wid, Heig: Integer); overload;
    procedure StretchDraw(DC: hDC; Left, Top, Wid, Heig: Integer);
  end;

implementation

var
  TableSin: array [0..359] of Real;
  TableCos: array [0..359] of Real;
  iTable: Integer;

function Signed(N: Integer): Integer;
begin
  if N = 0 then Result := 0;
  if N > 0 then Result := 1;
  if N < 0 then Result := -1;
end;

{ TScreen }

constructor TScreen.Create(DC: hDC; Wid, Heig: Integer);
begin
  Bpp := 3;
  Width := Wid; Height := Heig;
  with BmpInfo.bmiHeader do begin
    biSize          := SizeOf(TBitmapInfoHeader);
    biWidth         := Width;
    biHeight        := -Height;
    biPlanes        := 1;
    biBitCount      := 24;
    biCompression   := BI_RGB;
    biSizeImage     := Width*Height*Bpp;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biClrUsed       := 0;
    biClrImportant  := 0;
  end;
  Bmp := CreateDIBSection(DC,BmpInfo,0,Surface,0,0);
  ScreenDC := CreateCompatibleDC(DC);
  SelectObject(ScreenDC,Bmp);
end;

destructor TScreen.Destroy;
begin
  DeleteDC(ScreenDC);
  DeleteObject(Bmp);
end;

function TScreen.GetWidth: Integer;
begin
  Result := Width;
end;

function TScreen.GetHeight: Integer;
begin
  Result := Height;
end;

function TScreen.InBuffer(X, Y: Integer): Integer;
var
  Offset : Integer;
begin
  if (Width = 320) then
    Offset := (((Y shl 8) + (Y shl 6))*Bpp) + X * Bpp   // Fast
  else
    Offset := Y * (Width * Bpp) + X * Bpp;              // Slow
  if Offset < (Width*Height*Bpp) then
    Result := Offset
  else
    Result := -1;
end;

function TScreen.GetPixel(X, Y: Integer): TColorRef;
var
  R,G,B  : Byte;
  PBits  : PByte;
  Offset : Integer;
begin
  Offset := InBuffer(X,Y);
  if Offset = -1 then Exit;
  PBits := Surface;
  Inc(PBits,Offset);
  B := PBits^; Inc(PBits);
  G := PBits^; Inc(PBits);
  R := PBits^;
  Result := RGB(R,G,B);
end;

procedure TScreen.SetPixel(X, Y: Integer; Cor: TColorRef);
var
  PBits  : PByte;
  Offset : Integer;
begin
  Offset := InBuffer(X,Y);
  if Offset = -1 then Exit;
  PBits := Surface;
  Inc(PBits,Offset);
  PBits^ := GetBValue(Cor); Inc(PBits);
  PBits^ := GetGValue(Cor); Inc(PBits);
  PBits^ := GetRValue(Cor);
end;

procedure TScreen.Draw(DC: hDC; X, Y: Integer);
begin
  BitBlt(DC,X,Y,Width,Height,ScreenDC,0,0,SRCCOPY);
end;

procedure TScreen.Draw(DC: hDC; Left, Top, Wid, Heig: Integer);
begin
  BitBlt(DC,Left,Top,Wid,Heig,ScreenDC,0,0,SRCCOPY);
end;

procedure TScreen.StretchDraw(DC: hDC; Left, Top, Wid, Heig: Integer);
begin
  StretchBlt(DC,Left,Top,Wid,Heig,ScreenDC,0,0,Width,Height,SRCCOPY);
end;

procedure TScreen.LineSlow(XStart, YStart, XEnd, YEnd: Integer;
  Cor: TColorRef);
var
  SigX,SigY,AbsDX,AbsDY: Integer;
  pX,pY,dX,dY,i: Integer;
  V: Real;
begin
  if (XStart = XEnd) and (YStart = YEnd) then begin
    SetPixel(XStart,YStart,Cor);
    Exit;
  end;
  dX := XEnd - XStart;
  dY := YEnd - YStart;
  SigX := Signed(dX);
  SigY := Signed(dY);
  AbsDX := Abs(dX);
  AbsDY := Abs(dY);
  if AbsDX >= AbsDY then begin  // A linha é mais horizontal
    V := dY / dX; i := 0;
    while i <> dX do begin
      pX := i + XStart;
      pY := Round(V * i)+ YStart;
      SetPixel(pX,pY,Cor);
      i := i + SigX;
    end;
  end else begin                // A linha é mais vertical
    v := dX / dY; i := 0;
    while i <> dY do begin
      pX := Round(V * i) + XStart;
      pY := i + YStart;
      SetPixel(pX,pY,Cor);
      i := i + SigY;
    end;
  end;
end;

procedure TScreen.LineFast(XStart, YStart, XEnd, YEnd: Integer;
  Cor: TColorRef);
var
  SigDX,SigDY,AbsDX,AbsDY: Integer;
  pX,pY,dX,dY,X,Y,i: Integer;
begin
  if (XStart = XEnd) and (YStart = YEnd) then begin
    SetPixel(XStart,YStart,Cor);
    Exit;
  end;
  dX := XEnd - XStart;
  dY := YEnd - YStart;
  SigDX := Signed(dX);
  SigDY := Signed(dY);
  AbsDX := Abs(dX);
  AbsDY := Abs(dY);
  X := AbsDY shr 1;
  Y := AbsDX shr 1;
  pX := XStart;
  pY := YStart;
  SetPixel(pX,pY,Cor);
  if AbsDX >= AbsDY then begin  // A linha é mais horizontal
    for i := 0 to AbsDX - 1 do begin
      Y := Y + AbsDY;
      if Y >= AbsDX then begin
        Y := Y - AbsDX;
        pY := pY + SigDY;
      end;
      pX := pX + SigDX;
      SetPixel(pX,pY,Cor);
    end;
  end else begin                // A linha é mais vertical
    for i := 0 to AbsDY do begin
      X := X + AbsDX;
      if X >= AbsDY then begin
        X := X - AbsDY;
        pX := pX + SigDX;
      end;
      pY := pY + SigDY;
      SetPixel(pX,pY,Cor);
    end;
  end;
end;

procedure TScreen.Rectangle(XStart, YStart, XEnd, YEnd: Integer;
  Cor: TColorRef);
begin
  LineFast(XStart,YStart,XEnd,YStart,Cor);
  LineFast(XEnd,YStart,XEnd,YEnd,Cor);
  LineFast(XEnd,YEnd,XStart,YEnd,Cor);
  LineFast(XStart,YStart,XStart,YEnd,Cor);
end;

procedure TScreen.Polyline(Vertices: array of TPoint; Cor: TColorRef);
var
  i: Integer;
begin
  for i := Low(Vertices) to High(Vertices)-1 do
    LineFast(Vertices[i].x,Vertices[i].y,Vertices[i+1].x,Vertices[i+1].y,Cor);
  LineFast(Vertices[0].x,Vertices[0].y,Vertices[High(Vertices)].x,Vertices[High(Vertices)].y,Cor);
end;

procedure TScreen.Ellipse(X, Y, Raio: Integer; Cor: TColorRef);
var
  N: Real;
  IRaio: Real;
  dX: Integer;
  dY: Integer;
begin
  N := 0; IRaio := 1 / Raio;
  dX := 0; dY := Raio - 1;
  while dX <= dY do begin
    SetPixel(X + dY,Y - dX,Cor);  { 1 Octante }
    SetPixel(X + dX,Y - dY,Cor);  { 2 Octante }
    SetPixel(X - dX,Y - dY,Cor);  { 3 Octante }
    SetPixel(X - dY,Y - dX,Cor);  { 4 Octante }
    SetPixel(X - dY,Y + dY,Cor);  { 5 Octante }
    SetPixel(X - dX,Y + dY,Cor);  { 6 Octante }
    SetPixel(X + dX,Y + dY,Cor);  { 7 Octante }
    SetPixel(X + dY,Y + dX,Cor);  { 8 Octante }
    Inc(dX); N := N + IRaio;
//    dY := Raio * Sin(ACos(N));
  end;
end;

initialization

for iTable := 0 to 359 do begin
  TableSin[iTable] := Sin(iTable / 180 * PI);
  TableCos[iTable] := Cos(iTable / 180 * PI);
end;

end.
