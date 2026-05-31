# Generates PopupPlayer's toolbar icons at the four sizes Chrome uses.
# Draws a Picture-in-Picture glyph: an outer frame with a small "popup" window
# in the bottom-right corner and a play triangle inside it, on a rounded
# indigo gradient tile. Re-run after tweaking to regenerate the PNGs:
#   powershell -NoProfile -ExecutionPolicy Bypass -File generate-icons.ps1

Add-Type -AssemblyName System.Drawing

$outDir = $PSScriptRoot

function New-RoundedRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $d = $r * 2
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

function New-Icon([int]$S, [string]$file) {
    $bmp = New-Object System.Drawing.Bitmap($S, $S, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    # Rounded gradient background tile.
    $bgRect = New-Object System.Drawing.RectangleF(0, 0, $S, $S)
    $bgPath = New-RoundedRect 0 0 $S $S ($S * 0.22)
    $c1 = [System.Drawing.Color]::FromArgb(255, 99, 102, 241)   # indigo-500
    $c2 = [System.Drawing.Color]::FromArgb(255, 67, 56, 202)    # indigo-700
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, $c1, $c2, 45.0)
    $g.FillPath($grad, $bgPath)

    $white = [System.Drawing.Color]::White

    # Outer frame (the "screen"): white rounded outline.
    $c = $S * 0.18
    $fw = $S - 2 * $c
    $fh = $S - 2 * $c
    $penW = [Math]::Max(1.0, $S * 0.075)
    $pen = New-Object System.Drawing.Pen($white, $penW)
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $framePath = New-RoundedRect $c $c $fw $fh ($S * 0.13)
    $g.DrawPath($pen, $framePath)

    # Popup window: filled white rounded rect overlapping the bottom-right corner.
    $pw = $fw * 0.54
    $ph = $fh * 0.48
    $px = $S - $c - $pw + ($penW * 0.5)
    $py = $S - $c - $ph + ($penW * 0.5)
    # Backing pad behind the popup so it reads as sitting on top of the frame.
    $gapBrush = New-Object System.Drawing.SolidBrush($c2)
    $gi = $penW * 0.9
    $gapPath = New-RoundedRect ($px - $gi) ($py - $gi) ($pw + 2 * $gi) ($ph + 2 * $gi) ($S * 0.11)
    $g.FillPath($gapBrush, $gapPath)
    $popPath = New-RoundedRect $px $py $pw $ph ($S * 0.08)
    $whiteBrush = New-Object System.Drawing.SolidBrush($white)
    $g.FillPath($whiteBrush, $popPath)

    # Play triangle inside the popup (indigo, cut-out look). Only when big enough.
    if ($S -ge 32) {
        $cx = $px + $pw / 2
        $cy = $py + $ph / 2
        $t = $ph * 0.30
        $pts = @(
            (New-Object System.Drawing.PointF(($cx - $t * 0.55), ($cy - $t))),
            (New-Object System.Drawing.PointF(($cx - $t * 0.55), ($cy + $t))),
            (New-Object System.Drawing.PointF(($cx + $t * 0.85), $cy))
        )
        $triBrush = New-Object System.Drawing.SolidBrush($c2)
        $g.FillPolygon($triBrush, $pts)
        $triBrush.Dispose()
    }

    $path = Join-Path $outDir $file
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $pen.Dispose(); $gapBrush.Dispose(); $grad.Dispose(); $whiteBrush.Dispose()
    $g.Dispose(); $bmp.Dispose()
    Write-Host "wrote $file ($S x $S)"
}

New-Icon 16  "icon16.png"
New-Icon 32  "icon32.png"
New-Icon 48  "icon48.png"
New-Icon 128 "icon128.png"
