Add-Type -AssemblyName System.Drawing
$out = "c:\Users\loisj\Desktop\Altimètre"

# Même géométrie que le logo SVG de index.html (repère 48x48).
# Les deux extrémités tombent pile sur le cercle r=21 : 24 ± sqrt(21² - 10²) = 5.53 / 42.47
$RIDGE = @(@(5.53,34), @(14,23), @(18,27.5), @(24,14.5), @(30,24), @(34,20.5), @(42.47,34))

function New-Icon([int]$size, [string]$file, [double]$logoScale) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.ColorTranslator]::FromHtml("#07100F"))

  # halo discret
  $glow = New-Object System.Drawing.Drawing2D.GraphicsPath
  $glow.AddEllipse(-$size*0.2, -$size*0.5, $size*1.4, $size*1.5)
  $br = New-Object System.Drawing.Drawing2D.PathGradientBrush $glow
  $br.CenterColor = [System.Drawing.ColorTranslator]::FromHtml("#123A31")
  $br.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 7, 16, 15))
  $g.FillPath($br, $glow)

  $mint = [System.Drawing.ColorTranslator]::FromHtml("#5FE9AE")
  $k = $size / 48.0 * $logoScale
  $cx = $size / 2.0; $cy = $size / 2.0
  function P([double]$x, [double]$y) {
    New-Object System.Drawing.PointF (($cx + ($x - 24) * $k)), (($cy + ($y - 24) * $k))
  }

  # anneau
  $r = 21 * $k
  $penRing = New-Object System.Drawing.Pen $mint, ([float](2 * $k))
  $g.DrawEllipse($penRing, [float]($cx - $r), [float]($cy - $r), [float]($r * 2), [float]($r * 2))

  $pts = $RIDGE | ForEach-Object { P $_[0] $_[1] }

  # le massif repose sur l'arc inférieur du disque : crête puis retour par le cercle
  $fill = New-Object System.Collections.Generic.List[System.Drawing.PointF]
  $pts | ForEach-Object { $fill.Add($_) }
  $a0 = [Math]::Atan2(10.0, 18.47); $a1 = [Math]::PI - $a0
  for ($i = 0; $i -le 48; $i++) {
    $a = $a0 + ($a1 - $a0) * $i / 48
    $fill.Add((P (24 + 21 * [Math]::Cos($a)) (24 + 21 * [Math]::Sin($a))))
  }
  $g.FillPolygon((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(36, 95, 233, 174))), $fill.ToArray())

  # ligne de crête (bouts francs : ils rejoignent le trait du cercle)
  $pen = New-Object System.Drawing.Pen $mint, ([float](2 * $k))
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $g.DrawLines($pen, [System.Drawing.PointF[]]$pts)

  $g.Dispose()
  $path = Join-Path $out $file
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  "{0}  ({1}x{1})" -f $file, $size
}

New-Icon 512 "icon-512.png" 0.78     # zone sûre des icônes masquables
New-Icon 192 "icon-192.png" 0.78
New-Icon 180 "apple-touch-icon.png" 0.88
