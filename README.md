# 番茄 · 桌面专注计时器

一个无需安装依赖的 Windows 桌面番茄钟，使用系统自带的 PowerShell 与 WPF 构建。

## 下载

从 [Releases](https://github.com/TianleNiu/TomatoFocus/releases/latest) 下载最新版，解压后双击 `番茄钟.exe` 即可运行。

## 使用方法

双击 `番茄钟.exe` 即可运行，不会显示控制台窗口。

`启动番茄钟.vbs` 和 `启动番茄钟.bat` 作为兼容启动方式保留。

如修改源代码，可运行 `Build-App.ps1` 重新生成带图标的单文件程序。

功能包括：

- 专注、短休息和长休息三种模式
- 开始、暂停、重置与跳过
- 圆形进度与窗口标题倒计时
- 每 4 个番茄自动进入长休息
- 可调整各阶段时长并自动保存设置
- 阶段结束时播放提示音并发送 Windows 通知
- 本次运行的完成数量与专注分钟统计

设置保存在 `%LOCALAPPDATA%\TomatoFocus\settings.json`。
