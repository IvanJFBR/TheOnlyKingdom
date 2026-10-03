# System Patterns & Convenções Técnicas

## 1. Escala de Tiles (48x48)
- Todos os mapas e tilesets no Tiled devem usar **48×48 pixels** (padrão nativo do RMMZ).
- Tilesets RTP originais do RMMZ já vêm em 48px. Não cortar em 32px.

## 2. Parallax de Referência no Editor
- Utilizado como guia no editor do RMMZ para posicionamento visual de eventos (baús, NPCs, portas).
- **Dimensões exatas:** `(largura_em_tiles * 48) x (altura_em_tiles * 48)`.
  - Ex: Mapa de 17×13 tiles = **816×624 px**.
- **Exportação via CLI (tmxrasterizer):**
  ```powershell
  & "C:\Program Files\Tiled\tmxrasterizer.exe" --scale 1 maps\map1.json img\parallaxes\!map1.png
  ```
- O prefixo `!` no nome do arquivo impede o parallax de rolar com paralaxe infinito, fixando-o na grade 1:1.

## 3. Regra Crítica de Caminhos do VisuStella (`VisuMZ_5_TiledMZ.js`)
- O leitor do VisuStella executa `paths.shift()` no campo `"image"` do tileset.
- **Regra obrigatória:** Os arquivos JSON dos tilesets devem residir diretamente na pasta `maps/` e referenciar a imagem como `"../img/tilesets/<Nome>.png"`.
- Se o JSON estiver em subpastas como `maps/tilesets/`, o Tiled gravará `"../../img/..."`, quebrando o carregamento com erro 404.

## 4. Limite de Textura do RMMZ WebGL (1024×1024)
- Imagens de tileset não podem ultrapassar 1024px de largura ou altura.
- O gerador de terrenos decompõe folhas A2 em pacotes de no máximo 16 autotiles por imagem (768×768 px): `Outside_A2_Terrain1.png`, `Outside_A2_Terrain2.png`, etc.

## 5. Gerador de Terrenos (Wang Sets)
- Script: `Tiled\tools\make_terrain_tileset.ps1 -Name <NomeDoTilesetA2>`
- Gera tilesets de 16 peças de canto (`corner`) com automação de bordas e curvas idêntica ao RPG Maker.

## 6. Servidores MCP
- `tiled-ai`: Comunicação via ponte local na porta padrão. Conexão no Tiled via menu **Map → Tiled AI: Connect**.
- `rpgmaker-mz`: Servidor stdio localizado em `C:\Users\Ivan\OneDrive\Documentos\RMMZ\Usefulls\rpgmaker-mz-mcp\dist\index.js` para controle de banco de dados, mapas, eventos e variáveis.

## 7. Convenção de Camadas e Pastas (Group Layers) no Tiled
- As camadas do mapa devem ser agrupadas em 4 pastas principais (tipo `group`):
  1. **`Below`**: Camadas de terreno/chão abaixo dos personagens. Propriedade: `zIndex: 1` (int). Camadas filhas herdam esse valor.
  2. **`Same`**: Elementos na mesma altura dos personagens (troncos, mesas, muros). Propriedade: `zIndex: 3` (int).
  3. **`Above`**: Elementos acima dos personagens (copas de árvores, telhados). Propriedade: `zIndex: 4` (int).
  4. **`System`**: Camadas de sistema e metadados. Não possui `zIndex`. Contém as propriedades padrão:
     - `collision`: "tile-base" (string)
     - `flags`: "tile-base" (string)
     - `hiddenInGame`: true (bool)
     - `hideOnLevel`: 1 (int)
     - `level`: 0 (int)
     - `regionId`: "tile-base" (string)
     - `terrainTag`: "tile-base" (string)
     - `toLevel`: "tile-base" (string)
- O VisuStella MZ (`VisuMZ_5_TiledMZ.js`) extrai camadas recursivamente (`DataManager.recursiveExtractLayers`) e repassa as propriedades do grupo para as camadas filhas que não possuírem sobreposição individual.

