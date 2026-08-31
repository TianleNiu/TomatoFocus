using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

internal static class TomatoFocusLauncher
{
    [STAThread]
    private static void Main()
    {
        try
        {
            string runtimeDirectory = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "TomatoFocus", "runtime");
            Directory.CreateDirectory(runtimeDirectory);

            string scriptPath = Path.Combine(runtimeDirectory, "Pomodoro.ps1");
            string iconPath = Path.Combine(runtimeDirectory, "tomato-icon.ico");
            ExtractResource("Pomodoro.ps1", scriptPath);
            ExtractResource("tomato-icon.ico", iconPath);

            var startInfo = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = "-NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File \"" +
                            scriptPath + "\" -AppIconPath \"" + iconPath + "\"",
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                WorkingDirectory = runtimeDirectory
            };
            Process.Start(startInfo);
        }
        catch (Exception error)
        {
            System.Windows.Forms.MessageBox.Show(
                "番茄钟启动失败：\r\n" + error.Message, "番茄钟",
                System.Windows.Forms.MessageBoxButtons.OK,
                System.Windows.Forms.MessageBoxIcon.Error);
        }
    }

    private static void ExtractResource(string resourceName, string destination)
    {
        Assembly assembly = Assembly.GetExecutingAssembly();
        using (Stream input = assembly.GetManifestResourceStream(resourceName))
        {
            if (input == null) throw new InvalidOperationException("缺少资源：" + resourceName);
            using (var output = new FileStream(destination, FileMode.Create, FileAccess.Write, FileShare.Read))
                input.CopyTo(output);
        }
    }
}
