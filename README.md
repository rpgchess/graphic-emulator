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

- **Delphi 7+** ou **RAD Studio XE+** (para desenvolvimento e compilação)
- **Windows** (VCL é específico para Windows)

### Opção 1: Compilar com Delphi IDE (Recomendado)

1. Abrir `Emulador.dpr` no Delphi
2. Project > Build Emulador (ou pressionar **Shift+F9**)
3. Run > Run (ou pressionar **F9**)
4. Executável será gerado em:
   - Debug: `Win32\Debug\Emulador.exe`
   - Release: `Win32\Release\Emulador.exe`

### Opção 2: Compilar via Linha de Comando

```bash
# Com Delphi Command Line Compiler (dcc32.exe)
dcc32 -B Emulador.dpr

# Com MSBuild (RAD Studio XE2+)
msbuild Emulador.dproj /t:Build /p:Config=Release
```

### Opção 3: Executável Pré-compilado

```bash
# Após compilar, execute diretamente:
.\Emulador.exe
```

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

## ⚙️ Melhorias Implementadas

### ✅ Configuração
- **EditorConfig** adicionado para encoding UTF-8
- Configuração de indentação Delphi/Pascal
- Line endings Windows (CRLF) configurados
- Tratamento especial para arquivos binários (ROM, BMP, ICO)

### ✅ Documentação
- README expandido com exemplos de código
- Algoritmos explicados com código Pascal
- Múltiplas opções de compilação documentadas
- Formato de ROM documentado
- Controles de teclado mapeados
- Seção técnica de cada efeito

### 🔧 Melhorias Técnicas Possíveis

- [ ] Otimizar com assembly inline para loops críticos
- [ ] Suporte a DirectX para aceleração de hardware
- [ ] Adicionar mais efeitos (rotozoomer, metaballs, etc.)
- [ ] Editor de ROMs gráfico
- [ ] Exportar efeitos como vídeo (AVI/MP4)
- [ ] Sincronização com música (demo style)
- [ ] Suporte a shaders modernos
- [ ] Modo retro com resolução baixa (320x200)

## 📚 Recursos e Referências

### Demoscene
- [Pouët.net](https://www.pouet.net/) - Arquivo de demos
- [256b.com](https://www.256b.com/) - Size-coding
- [Hugi](http://www.hugi.scene.org/) - Revista demoscene

### Algoritmos Gráficos
- Fire Effect: [Hugo Elias Tutorial](http://freespace.virgin.net/hugo.elias/models/m_fire.htm)
- Plasma: [Lode's Computer Graphics Tutorial](https://lodev.org/cgtutor/plasma.html)
- Tunnel: [Lode's Computer Graphics Tutorial](https://lodev.org/cgtutor/tunnel.html)

### Delphi Graphics
- [VCL Graphics](https://docwiki.embarcadero.com/Libraries/en/Vcl.Graphics)
- [TBitmap Reference](https://docwiki.embarcadero.com/Libraries/en/Vcl.Graphics.TBitmap)
- [ScanLine Property](https://docwiki.embarcadero.com/Libraries/en/Vcl.Graphics.TBitmap.ScanLine)

## 🎮 Efeitos Clássicos da Demoscene

Este emulador implementa efeitos icônicos da era de ouro da demoscene:

1. **Fire Effect** - Popularizado por demos do Amiga (1990s)
2. **Plasma** - Clássico dos demos 4KB/64KB
3. **Tunnel** - Efeito 3D sem aceleração de hardware
4. **TV Noise** - Simulação de ruído analógico

## 👨‍💻 Autor

Claudio Almeida

## 📝 Licença

Projeto educacional.

---

> **Nostalgia**: Inspirado nos clássicos efeitos demoscene da era 8/16 bits (Commodore 64, Amiga, DOS).

