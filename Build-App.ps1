$ErrorActionPreference = 'Stop'

$projectDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePng = Join-Path $projectDirectory 'tomato-icon.png'
$cleanPng = Join-Path $projectDirectory 'tomato-icon-transparent.png'
$iconPath = Join-Path $projectDirectory 'tomato-icon.ico'
$scriptPath = Join-Path $projectDirectory 'Pomodoro.ps1'
$launcherPath = Join-Path $projectDirectory 'TomatoFocusLauncher.cs'
$outputPath = Join-Path $projectDirectory '番茄钟.exe'

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;

public static class TomatoIconBuilder
{
    public static void Build(string sourcePath, string transparentPngPath, string iconPath)
    {
        using (var sourceFile = new Bitmap(sourcePath))
        using (var image = new Bitmap(sourceFile.Width, sourceFile.Height, PixelFormat.Format32bppArgb))
        {
            using (Graphics g = Graphics.FromImage(image)) g.DrawImageUnscaled(sourceFile, 0, 0);

            for (int y = 0; y < image.Height; y++)
            for (int x = 0; x < image.Width; x++)
            {
                Color c = image.GetPixel(x, y);
                int max = Math.Max(c.R, Math.Max(c.G, c.B));
                int min = Math.Min(c.R, Math.Min(c.G, c.B));
                int average = (c.R + c.G + c.B) / 3;
                if ((max - min) < 18 && average > 150)
                    image.SetPixel(x, y, Color.Transparent);
            }

            image.Save(transparentPngPath, ImageFormat.Png);
            int[] sizes = { 16, 24, 32, 48, 64, 128, 256 };
            var frames = new List<byte[]>();
            foreach (int size in sizes)
            {
                using (var resized = new Bitmap(size, size, PixelFormat.Format32bppArgb))
                using (Graphics g = Graphics.FromImage(resized))
                using (var stream = new MemoryStream())
                {
                    g.Clear(Color.Transparent);
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                    g.DrawImage(image, new Rectangle(0, 0, size, size));
                    resized.Save(stream, ImageFormat.Png);
                    frames.Add(stream.ToArray());
                }
            }

            using (var file = new FileStream(iconPath, FileMode.Create, FileAccess.Write))
            using (var writer = new BinaryWriter(file))
            {
                writer.Write((ushort)0); writer.Write((ushort)1); writer.Write((ushort)sizes.Length);
                int offset = 6 + 16 * sizes.Length;
                for (int i = 0; i < sizes.Length; i++)
                {
                    writer.Write((byte)(sizes[i] == 256 ? 0 : sizes[i]));
                    writer.Write((byte)(sizes[i] == 256 ? 0 : sizes[i]));
                    writer.Write((byte)0); writer.Write((byte)0);
                    writer.Write((ushort)1); writer.Write((ushort)32);
                    writer.Write((uint)frames[i].Length); writer.Write((uint)offset);
                    offset += frames[i].Length;
                }
                foreach (byte[] frame in frames) writer.Write(frame);
            }
        }
    }
}
'@

[TomatoIconBuilder]::Build($sourcePng, $cleanPng, $iconPath)

$scriptText = [IO.File]::ReadAllText($scriptPath, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText($scriptPath, $scriptText, [Text.UTF8Encoding]::new($true))

$compiler = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $compiler)) {
    $compiler = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe'
}
if (-not (Test-Path -LiteralPath $compiler)) { throw '找不到系统 C# 编译器。' }

& $compiler /nologo /target:winexe /platform:anycpu /optimize+ `
    "/win32icon:$iconPath" `
    "/resource:$scriptPath,Pomodoro.ps1" `
    "/resource:$iconPath,tomato-icon.ico" `
    '/reference:System.dll' `
    '/reference:System.Windows.Forms.dll' `
    "/out:$outputPath" `
    $launcherPath

if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath)) { throw 'EXE 编译失败。' }
Write-Host "Built: $outputPath"
