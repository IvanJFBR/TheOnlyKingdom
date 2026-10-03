# Converte um tileset de autotiles A2 do RPG Maker MZ em um tileset de terreno
# (Wang "corner") para o Tiled. Cada autotile vira 16 tiles de 48x48.
# O RMMZ só aceita imagens de tileset de até 1024x1024, então a saída é dividida
# em partes de 16 autotiles (768x768): <Name>_Terrain1, <Name>_Terrain2, ...
# Uso: powershell -File Tiled\tools\make_terrain_tileset.ps1 -Name Outside_A2
param([string]$Name = "Outside_A2")

Add-Type -AssemblyName System.Drawing
$root = Resolve-Path "$PSScriptRoot\..\.."
$src  = [System.Drawing.Image]::FromFile("$root\img\tilesets\$Name.png")
$blocksX = [int]($src.Width / 96); $blocksY = [int]($src.Height / 144)
$total = $blocksX * $blocksY

# Pedaço (quarto de 24px) do autotile RM para cada canto da célula.
function Q-BR($r,$d,$x){ if($r -and $d){ if($x){@(2,4)}else{@(3,1)} } elseif($r){@(2,5)} elseif($d){@(3,4)} else{@(3,5)} }
function Q-BL($l,$d,$x){ if($l -and $d){ if($x){@(1,4)}else{@(2,1)} } elseif($l){@(1,5)} elseif($d){@(0,4)} else{@(0,5)} }
function Q-TR($u,$r,$x){ if($u -and $r){ if($x){@(2,3)}else{@(3,0)} } elseif($r){@(2,2)} elseif($u){@(3,3)} else{@(3,2)} }
function Q-TL($u,$l,$x){ if($u -and $l){ if($x){@(1,3)}else{@(2,0)} } elseif($l){@(1,2)} elseif($u){@(0,3)} else{@(0,2)} }

for ($part = 0; $part * 16 -lt $total; $part++) {
$first = $part * 16
$count = [math]::Min(16, $total - $first)
$out = New-Object System.Drawing.Bitmap (16 * 48), ($count * 48)
$g = [System.Drawing.Graphics]::FromImage($out)

$wangsets = @()
for ($a = 0; $a -lt $count; $a++) {
  $ga = $first + $a
  $bx = ($ga % $blocksX) * 96; $by = [math]::Floor($ga / $blocksX) * 144
  $tiles = @()
  for ($m = 0; $m -lt 16; $m++) {
    $tl = ($m -band 1) -ne 0; $tr = ($m -band 2) -ne 0; $br = ($m -band 4) -ne 0; $bl = ($m -band 8) -ne 0
    $parts = @(
      @($tl, (Q-BR $tr $bl $br), 0, 0),
      @($tr, (Q-BL $tl $br $bl), 24, 0),
      @($bl, (Q-TR $tl $br $tr), 0, 24),
      @($br, (Q-TL $tr $bl $tl), 24, 24))
    foreach ($p in $parts) {
      if (-not $p[0]) { continue }
      $q = $p[1]
      $dst = New-Object System.Drawing.Rectangle ($m * 48 + $p[2]), ($a * 48 + $p[3]), 24, 24
      $g.DrawImage($src, $dst, ($bx + $q[0] * 24), ($by + $q[1] * 24), 24, 24, [System.Drawing.GraphicsUnit]::Pixel)
    }
    $c = { param($b) if ($b) { 1 } else { 0 } }
    # wangid: top, topright, right, bottomright, bottom, bottomleft, left, topleft
    $tiles += [ordered]@{ tileid = $a * 16 + $m; wangid = @(0, (& $c $tr), 0, (& $c $br), 0, (& $c $bl), 0, (& $c $tl)) }
  }
  $wangsets += [ordered]@{
    name = "{0} #{1:D2}" -f $Name, ($ga + 1); type = "corner"; tile = $a * 16 + 15
    colors = @([ordered]@{ name = "Terreno"; color = "#ff7f00"; tile = $a * 16 + 15; probability = 1 })
    wangtiles = $tiles }
}
$g.Dispose()
$tn = "${Name}_Terrain$($part + 1)"
$out.Save("$root\img\tilesets\$tn.png", [System.Drawing.Imaging.ImageFormat]::Png); $out.Dispose()

$json = [ordered]@{
  columns = 16; image = "../img/tilesets/$tn.png"; imagewidth = 768; imageheight = $count * 48
  margin = 0; spacing = 0; name = $tn; tilecount = $count * 16; tilewidth = 48; tileheight = 48
  tiledversion = "1.12.2"; type = "tileset"; version = "1.10"; wangsets = $wangsets
} | ConvertTo-Json -Depth 10 -Compress
[System.IO.File]::WriteAllText("$root\maps\$tn.json", $json)
# Também salva em maps\tilesets\ para compatibilidade se aberto de lá
[System.IO.File]::WriteAllText("$root\maps\tilesets\$tn.json", $json)
"OK: terrenos $($first + 1)-$($first + $count) -> maps\$tn.json"
}
$src.Dispose()
