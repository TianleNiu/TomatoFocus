Option Explicit

Dim shell, fileSystem, appPath, command
Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

appPath = fileSystem.BuildPath(fileSystem.GetParentFolderName(WScript.ScriptFullName), "Pomodoro.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File " & Chr(34) & appPath & Chr(34)

shell.Run command, 0, False
