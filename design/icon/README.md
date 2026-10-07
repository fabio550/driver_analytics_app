# Ícone do app

Carro subindo numa linha de tendência sobre um gráfico de barras
ascendente — "dirigir" + "ganhos crescendo", a cara do app.

- `icon.svg` — ícone completo (com fundo em gradiente azul), usado como
  o `ic_launcher` legado (`android/app/src/main/res/mipmap-*/ic_launcher.png`).
- `icon_foreground.svg` — só o símbolo, branco, fundo transparente,
  recentralizado e reduzido pra caber na "zona segura" do ícone
  adaptativo do Android (círculo de ~66% do canvas — o SO pode recortar
  qualquer coisa fora disso com máscaras diferentes por fabricante).
  Usado em `mipmap-*/ic_launcher_foreground.png` e também (no modo
  escuro) na splash screen.
- `icon_foreground_dark.svg` — mesmo símbolo, em azul (`#2E5CFF`, a cor
  semente do tema em `app_colors.dart`) em vez de branco, pra usar sobre
  fundo claro. Usado na splash screen no modo claro.

Cor de fundo do ícone adaptativo: `#2E5CFF`, em
`android/app/src/main/res/values/colors.xml` (`ic_launcher_background`).

## Como regenerar

Os PNGs finais foram renderizados a partir desses SVGs (via Chromium
headless + Pillow pra redimensionar) e colocados direto nas pastas de
resource do Android — não há um passo de build automatizado pra isso
no projeto hoje. Pra mudar o ícone:

1. Edita o(s) SVG(s) aqui.
2. Renderiza cada um em 1024×1024 (qualquer ferramenta de SVG→PNG serve
   — Inkscape, `rsvg-convert`, ou um navegador headless).
3. Redimensiona pros tamanhos abaixo e substitui os arquivos
   correspondentes em `android/app/src/main/res/`:

   **Launcher legado** (`icon.svg` → `mipmap-*/ic_launcher.png`):
   mdpi 48px, hdpi 72px, xhdpi 96px, xxhdpi 144px, xxxhdpi 192px.

   **Ícone adaptativo** (`icon_foreground.svg` → `mipmap-*/ic_launcher_foreground.png`,
   spec de 108dp do Android): mdpi 108px, hdpi 162px, xhdpi 216px,
   xxhdpi 324px, xxxhdpi 432px.

   **Splash** (`icon_foreground.svg`/`icon_foreground_dark.svg` →
   `drawable-nodpi/splash_icon_dark.png`/`splash_icon_light.png`):
   480px basta (fica só um instante na tela, não precisa de várias
   densidades).

Se o projeto crescer pra precisar disso com mais frequência, vale a
pena migrar pra `flutter_launcher_icons` + `flutter_native_splash`
(ambos automatizam exatamente esses passos a partir de uma imagem
fonte) — não foram usados agora só porque essa sessão não tem o SDK
Flutter completo pra rodar os geradores, só o Dart puro.
