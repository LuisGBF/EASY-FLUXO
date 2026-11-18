Add-Type -AssemblyName System.Drawing

$root = "C:\dev\ciclolivre\android\app\src\main\res"
$rose = [System.Drawing.Color]::FromArgb(255, 225, 29, 72)
$roseDark = [System.Drawing.Color]::FromArgb(255, 190, 18, 60)
$white = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)

function New-HeartPath([float]$x, [float]$y, [float]$w, [float]$h) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $cx = $x + $w / 2
  $top = $y
  $bottom = $y + $h
  $p.StartFigure()
  $p.AddBezier($cx, $bottom, $x, $y + $h * 0.62, $x, $top + $h * 0.05, $cx, $top + $h * 0.24)
  $p.AddBezier($cx, $top + $h * 0.24, $x + $w, $top + $h * 0.05, $x + $w, $y + $h * 0.62, $cx, $bottom)
  $p.CloseFigure()
  return $p
}

function New-Icon([int]$size, [string]$path, [bool]$round, [bool]$fullBleed, [double]$heartScale) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)

  $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
  if ($round) {
    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gp.AddEllipse($rect)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $rose, $roseDark, 45)
    $g.FillPath($brush, $gp)
  } elseif ($fullBleed) {
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $rose, $roseDark, 45)
    $g.FillRectangle($brush, $rect)
  }

  $hSize = [float]($size * $heartScale)
  $hx = ($size - $hSize) / 2
  $hy = ($size - $hSize) / 2 + ($size * 0.02)
  $heart = New-HeartPath $hx $hy $hSize ($hSize * 0.94)
  $wb = New-Object System.Drawing.SolidBrush($white)
  $g.FillPath($wb, $heart)

  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
}

function New-Splash([int]$w, [int]$h, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
  $g.Clear([System.Drawing.Color]::FromArgb(255, 250, 250, 249))

  $logo = [Math]::Min($w, $h) * 0.28
  $lx = ($w - $logo) / 2
  $ly = ($h - $logo) / 2 - ($h * 0.04)

  $rect = New-Object System.Drawing.Rectangle([int]$lx, [int]$ly, [int]$logo, [int]$logo)
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $rose, $roseDark, 45)
  $rounded = New-Object System.Drawing.Drawing2D.GraphicsPath
  $r = $logo * 0.28
  $rounded.AddArc($lx, $ly, $r * 2, $r * 2, 180, 90)
  $rounded.AddArc(($lx + $logo - $r * 2), $ly, $r * 2, $r * 2, 270, 90)
  $rounded.AddArc(($lx + $logo - $r * 2), ($ly + $logo - $r * 2), $r * 2, $r * 2, 0, 90)
  $rounded.AddArc($lx, ($ly + $logo - $r * 2), $r * 2, $r * 2, 90, 90)
  $rounded.CloseFigure()
  $g.FillPath($brush, $rounded)

  $hSize = [float]($logo * 0.52)
  $heart = New-HeartPath ($lx + ($logo - $hSize) / 2) ($ly + ($logo - $hSize) / 2 + $logo * 0.03) $hSize ($hSize * 0.94)
  $g.FillPath((New-Object System.Drawing.SolidBrush($white)), $heart)

  $family = New-Object System.Drawing.FontFamily("Segoe UI")
  $fsize = [float]([Math]::Min($w, $h) * 0.055)
  $font = New-Object System.Drawing.Font($family, $fsize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $tbrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 28, 25, 23))
  $fmt = New-Object System.Drawing.StringFormat
  $fmt.Alignment = [System.Drawing.StringAlignment]::Center
  $titleRect = New-Object System.Drawing.RectangleF(0, [float]($ly + $logo + $h * 0.03), [float]$w, [float]($fsize * 1.6))
  $g.DrawString("CicloLivre", $font, $tbrush, $titleRect, $fmt)

  $fsize2 = [float]([Math]::Min($w, $h) * 0.028)
  $font2 = New-Object System.Drawing.Font($family, $fsize2, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $brush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 113, 108))
  $subRect = New-Object System.Drawing.RectangleF(0, [float]($ly + $logo + $h * 0.03 + $fsize * 1.5), [float]$w, [float]($fsize2 * 1.6))
  $g.DrawString("Acompanhamento real & sem julgamentos", $font2, $brush2, $subRect, $fmt)

  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
}

$map = @{ 'mdpi' = 1.0; 'hdpi' = 1.5; 'xhdpi' = 2.0; 'xxhdpi' = 3.0; 'xxxhdpi' = 4.0 }
foreach ($k in $map.Keys) {
  $d = $map[$k]
  $dir = Join-Path $root "mipmap-$k"
  New-Icon ([int](48 * $d)) (Join-Path $dir 'ic_launcher.png') $false $true 0.56
  New-Icon ([int](48 * $d)) (Join-Path $dir 'ic_launcher_round.png') $true $true 0.56
  New-Icon ([int](108 * $d)) (Join-Path $dir 'ic_launcher_foreground.png') $false $false 0.40
}

# Adaptive icon (Android 8+) aponta para o background em cor
@"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#E11D48</color>
</resources>
"@ | Set-Content (Join-Path $root 'values\ic_launcher_background.xml') -Encoding UTF8

# Splash screens em todas as densidades do template
$splash = @{
  ''                     = @(480, 800)
  'land-mdpi'            = @(480, 320)
  'land-hdpi'            = @(800, 480)
  'land-xhdpi'           = @(1280, 720)
  'land-xxhdpi'          = @(1600, 960)
  'land-xxxhdpi'         = @(1920, 1280)
  'port-mdpi'            = @(320, 480)
  'port-hdpi'            = @(480, 800)
  'port-xhdpi'           = @(720, 1280)
  'port-xxhdpi'          = @(960, 1600)
  'port-xxxhdpi'         = @(1280, 1920)
}
foreach ($k in $splash.Keys) {
  $dir = if ($k -eq '') { Join-Path $root 'drawable' } else { Join-Path $root "drawable-$k" }
  New-Splash $splash[$k][0] $splash[$k][1] (Join-Path $dir 'splash.png')
}

Write-Output "Icones e splash gerados."
