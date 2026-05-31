# Generates PopupPlayer's toolbar icons at the four sizes Chrome uses.
# Draws a Material-style picture-in-picture glyph (outer frame + a small popup
# window in the bottom-right corner with a play-triangle cut-out) in deep purple
# on a transparent background. Re-run after tweaking to regenerate the PNGs:
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

    # Deep purple glyph (Material 3 primary tone) on a transparent background.
    $ink = [System.Drawing.Color]::FromArgb(255, 103, 80, 164)

    # Outer frame (the "screen"): rounded outline.
    $c = $S * 0.16
    $fw = $S - 2 * $c
    $fh = $S - 2 * $c
    $penW = [Math]::Max(1.0, $S * 0.085)
    $pen = New-Object System.Drawing.Pen($ink, $penW)
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $framePath = New-RoundedRect $c $c $fw $fh ($S * 0.16)
    $g.DrawPath($pen, $framePath)

    # Popup window: filled rounded rect tucked inside the bottom-right corner,
    # clear of the frame stroke (Material picture_in_picture_alt style).
    $m = $penW * 0.9                      # margin from the inner edge of the frame
    $pw = $fw * 0.46
    $ph = $fh * 0.42
    $px = $c + $fw - $penW / 2 - $m - $pw
    $py = $c + $fh - $penW / 2 - $m - $ph
    $popPath = New-RoundedRect $px $py $pw $ph ($S * 0.07)

    # Play triangle as a transparent cut-out via even-odd fill (anti-aliased).
    if ($S -ge 32) {
        $cx = $px + $pw / 2
        $cy = $py + $ph / 2
        $t = $ph * 0.28
        $tri = New-Object System.Drawing.Drawing2D.GraphicsPath
        $tri.AddPolygon(@(
            (New-Object System.Drawing.PointF(($cx - $t * 0.55), ($cy - $t))),
            (New-Object System.Drawing.PointF(($cx - $t * 0.55), ($cy + $t))),
            (New-Object System.Drawing.PointF(($cx + $t * 0.85), $cy))
        ))
        $popPath.AddPath($tri, $false)
        $popPath.FillMode = [System.Drawing.Drawing2D.FillMode]::Alternate
        $tri.Dispose()
    }

    $popBrush = New-Object System.Drawing.SolidBrush($ink)
    $g.FillPath($popBrush, $popPath)

    $path = Join-Path $outDir $file
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $pen.Dispose(); $popBrush.Dispose()
    $framePath.Dispose(); $popPath.Dispose()
    $g.Dispose(); $bmp.Dispose()
    Write-Host "wrote $file ($S x $S)"
}

New-Icon 16  "icon16.png"
New-Icon 32  "icon32.png"
New-Icon 48  "icon48.png"
New-Icon 128 "icon128.png"
