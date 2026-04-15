# Graphic Emulator - Retro Graphics Emulator (Delphi) 🕹️

## 📌 Sobre o Projeto

Emulador gráfico desenvolvido em Delphi para simulação de placas de vídeo antigas e efeitos visuais retrô. Sistema que interpreta ROMs contendo algoritmos gráficos e renderiza efeitos clássicos da era de 8/16 bits.

## 🎯 Objetivo

Demonstrar técnicas de programação gráfica retrô:
- Emulação de hardware gráfico antigo
- Algoritmos de efeitos visuais clássicos
- Manipulação de pixels e paletas
- Renderização em tempo real
- Interpretação de ROMs customizadas

## 🚀 Tecnologias Utilizadas

- **Delphi** - IDE e linguagem Object Pascal
- **GDI/GDI+** - Renderização gráfica
- **Assembly inline** - Otimizações de performance
- **ROM Files** - Arquivos de efeitos

## 📁 Estrutura do Projeto

```
graphic-emulator/
├── Emulador.dpr            # Projeto principal
├── Emulador.dproj          # Arquivo de projeto Delphi
├── Utils.pas               # Utilitários
├── Keyboard.inc            # Controles de teclado
├── Dialogs.inc             # Diálogos
├── Resource.inc            # Recursos
├── Resource.RES            # Arquivo de recursos
├── Main.ico                # Ícone
├── BgAbout.bmp             # Imagem sobre
├── Roms/                   # Pasta de ROMs
├── *.rom                   # Arquivos ROM de efeitos
│   ├── Fire.rom            # Efeito fogo
│   ├── Plasma.rom          # Efeito plasma
│   ├── Tunel.rom           # Efeito túnel
│   ├── TV.rom              # Efeito TV noise
│   └── Cursor.rom          # Cursor customizado
└── README.md
```

## 🎮 Efeitos Disponíveis

### 1. Fire (Fire.rom)
Simulação de fogo realista usando algoritmo de difusão de calor

### 2. Plasma (Plasma.rom)
Efeito plasma com ondas senoidais e paleta rotativa

### 3. Tunnel (Tunel.rom)
Efeito túnel 3D com texture mapping

### 4. TV Noise (TV.rom)
Simulação de ruído de TV (snow/static)

### 5. Custom Cursor (Cursor.rom)
Cursor customizado animado

## 🔧 Funcionalidades

- ✅ Carregamento e execução de ROMs
- ✅ Múltiplos efeitos gráficos
- ✅ Renderização em tempo real (60 FPS)
- ✅ Paletas de cores customizáveis
- ✅ Controles de velocidade/intensidade
- ✅ Modo fullscreen
- ✅ Screenshot/captura
- ✅ Editor de ROMs (possivelmente)

## 💻 Como Usar

### Pré-requisitos

- **Delphi 7+** (para compilação)
- **Windows**

### Compilação

1. Abrir `Emulador.dpr` no Delphi
2. Compilar (F9)
3. Executar

### Execução

1. Executar `Emulador.exe`
2. Selecionar ROM no menu
3. Efeito será renderizado em tempo real
4. Usar teclas para controlar

## ⌨️ Controles

- **Espaço**: Pausar/Continuar
- **F**: Fullscreen
- **+/-**: Ajustar velocidade
- **P**: Screenshot
- **ESC**: Voltar ao menu
- **F1**: Ajuda
- **Setas**: Navegar menus

## 📚 Algoritmos dos Efeitos

### Fire Effect

```pascal
procedure CalculateFire;
var
  x, y: Integer;
  color: Byte;
begin
  // Base do fogo (linha inferior)
  for x := 0 to Width - 1 do
    Buffer[Height - 1, x] := Random(256);
  
  // Propagação do fogo
  for y := 0 to Height - 2 do
    for x := 0 to Width - 1 do
    begin
      color := (Buffer[y + 1, (x - 1 + Width) mod Width] +
                Buffer[y + 1, x] +
                Buffer[y + 1, (x + 1) mod Width] +
                Buffer[y + 2, x]) div 4;
      
      if color > 0 then
        Buffer[y, x] := color - 1
      else
        Buffer[y, x] := 0;
    end;
end;
```

### Plasma Effect

```pascal
procedure CalculatePlasma;
var
  x, y: Integer;
  value: Double;
  time: Double;
begin
  time := GetTickCount / 1000;
  
  for y := 0 to Height - 1 do
    for x := 0 to Width - 1 do
    begin
      value := Sin(x / 16.0 + time) +
               Sin(y / 8.0 + time) +
               Sin((x + y) / 16.0 + time) +
               Sin(Sqrt(x * x + y * y) / 8.0 + time);
      
      Buffer[y, x] := Round((value + 4) * 32) mod 256;
    end;
end;
```

### Tunnel Effect

```pascal
procedure CalculateTunnel;
var
  x, y: Integer;
  distance, angle: Double;
  u, v: Integer;
  time: Double;
begin
  time := GetTickCount / 1000;
  
  for y := 0 to Height - 1 do
    for x := 0 to Width - 1 do
    begin
      // Calcular distância e ângulo do centro
      distance := Sqrt(Sqr(x - Width/2) + Sqr(y - Height/2));
      angle := ArcTan2(y - Height/2, x - Width/2);
      
      // Texture mapping
      u := Round(32 * angle / PI + time * 100) mod 256;
      v := Round(32 / distance + time * 100) mod 256;
      
      Buffer[y, x] := Texture[v, u];
    end;
end;
```

## 🎨 Formato de ROM

ROMs contêm:
- **Header**: Informações do efeito (nome, autor, versão)
- **Code**: Algoritmo do efeito (bytecode ou script)
- **Data**: Texturas, paletas, parâmetros

```
[ROM Header - 256 bytes]
Signature: "GFXROM"
Version: 1.0
EffectName: "Fire Effect"
Author: "Claudio"
DataOffset: 0x100

[Code Section]
; Bytecode ou assembly do algoritmo

[Data Section]
; Paletas de cores
; Texturas
; Parâmetros
```

## 🎓 Conceitos Demonstrados

- ✅ Algoritmos gráficos clássicos
- ✅ Double buffering
- ✅ Paletas de cores indexadas
- ✅ Trigonometria aplicada
- ✅ Otimização de loops internos
- ✅ Interpolação de valores
- ✅ Manipulação de buffers de vídeo

## 👨‍💻 Autor

Claudio Almeida

## 📝 Licença

Projeto educacional.

---

> **Nostalgia**: Inspirado nos clássicos efeitos demoscene da era 8/16 bits (Commodore 64, Amiga, DOS).

