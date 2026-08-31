param([string]$AppIconPath)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="番茄 · 专注计时器" Width="520" Height="760"
        MinWidth="460" MinHeight="700" WindowStartupLocation="CenterScreen"
        Background="#F6F3EE" FontFamily="Microsoft YaHei UI"
        ResizeMode="CanResizeWithGrip">
  <Window.Resources>
    <SolidColorBrush x:Key="Ink" Color="#24332F"/>
    <SolidColorBrush x:Key="Muted" Color="#75827D"/>
    <SolidColorBrush x:Key="Tomato" Color="#E45B4D"/>
    <SolidColorBrush x:Key="Leaf" Color="#3E7865"/>
    <Style TargetType="Button">
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding" Value="18,10"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="12" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="Opacity" Value="0.86"/></Trigger>
              <Trigger Property="IsPressed" Value="True"><Setter TargetName="border" Property="Opacity" Value="0.72"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style TargetType="Slider">
      <Setter Property="Foreground" Value="{StaticResource Tomato}"/>
    </Style>
  </Window.Resources>

  <Grid Margin="34,28,34,24">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <Grid Grid.Row="0">
      <StackPanel>
        <TextBlock Text="番茄" FontSize="29" FontWeight="Bold" Foreground="{StaticResource Ink}"/>
        <TextBlock Text="把注意力留给眼前这一件事" Margin="1,4,0,0" FontSize="13" Foreground="{StaticResource Muted}"/>
      </StackPanel>
      <Button x:Name="SettingsButton" Content="设置" HorizontalAlignment="Right" VerticalAlignment="Center"
              Background="#E9E5DE" Foreground="{StaticResource Ink}" Padding="15,8"/>
    </Grid>

    <Border Grid.Row="1" Margin="0,24,0,0" Background="#EDE9E2" CornerRadius="14" Padding="5">
      <UniformGrid Columns="3">
        <Button x:Name="FocusMode" Content="专注" Background="#FFFFFF" Foreground="{StaticResource Tomato}"/>
        <Button x:Name="ShortMode" Content="短休息" Background="Transparent" Foreground="{StaticResource Muted}"/>
        <Button x:Name="LongMode" Content="长休息" Background="Transparent" Foreground="{StaticResource Muted}"/>
      </UniformGrid>
    </Border>

    <Grid Grid.Row="2" Margin="0,22,0,18">
      <Viewbox Stretch="Uniform" MaxWidth="330" MaxHeight="330">
        <Grid Width="310" Height="310">
          <Ellipse Stroke="#E5E0D8" StrokeThickness="13"/>
          <Path x:Name="ProgressArc" Stroke="#E45B4D" StrokeThickness="13" StrokeStartLineCap="Round" StrokeEndLineCap="Round"/>
          <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
            <TextBlock x:Name="ModeLabel" Text="专注时间" HorizontalAlignment="Center" FontSize="14" Foreground="{StaticResource Muted}"/>
            <TextBlock x:Name="TimeText" Text="25:00" HorizontalAlignment="Center" Margin="0,2,0,0"
                       FontFamily="Segoe UI" FontSize="66" FontWeight="SemiBold" Foreground="{StaticResource Ink}"/>
            <TextBlock x:Name="SessionLabel" Text="第 1 个番茄" HorizontalAlignment="Center" Margin="0,6,0,0" FontSize="13" Foreground="{StaticResource Muted}"/>
          </StackPanel>
        </Grid>
      </Viewbox>
    </Grid>

    <StackPanel Grid.Row="3">
      <TextBox x:Name="TaskBox" Text="准备专注的事情…" FontSize="14" Foreground="{StaticResource Muted}"
               Background="#FFFFFF" BorderBrush="#E7E1D9" BorderThickness="1" Padding="14,11" Margin="0,0,0,16"/>
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/><ColumnDefinition Width="12"/><ColumnDefinition Width="2*"/><ColumnDefinition Width="12"/><ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="ResetButton" Grid.Column="0" Content="重置" Background="#E9E5DE" Foreground="{StaticResource Ink}"/>
        <Button x:Name="StartButton" Grid.Column="2" Content="开始专注" Background="{StaticResource Tomato}" Foreground="White" Padding="20,14" FontSize="16"/>
        <Button x:Name="SkipButton" Grid.Column="4" Content="跳过" Background="#E9E5DE" Foreground="{StaticResource Ink}"/>
      </Grid>
    </StackPanel>

    <Border Grid.Row="4" Margin="0,22,0,0" Background="#FFFFFF" CornerRadius="14" Padding="16,12">
      <Grid>
        <StackPanel Orientation="Horizontal">
          <TextBlock Text="今日完成" Foreground="{StaticResource Muted}" FontSize="13"/>
          <TextBlock x:Name="CompletedText" Text=" 0 个番茄" Foreground="{StaticResource Ink}" FontWeight="SemiBold" FontSize="13"/>
        </StackPanel>
        <TextBlock x:Name="TotalFocusText" Text="专注 0 分钟" HorizontalAlignment="Right" Foreground="{StaticResource Leaf}" FontWeight="SemiBold" FontSize="13"/>
      </Grid>
    </Border>

    <Border x:Name="SettingsPanel" Grid.RowSpan="5" Visibility="Collapsed" Background="#F6F3EE" CornerRadius="18" Padding="26" Panel.ZIndex="10">
      <Grid>
        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Grid>
          <TextBlock Text="计时设置" FontSize="24" FontWeight="Bold" Foreground="{StaticResource Ink}"/>
          <Button x:Name="CloseSettings" Content="完成" HorizontalAlignment="Right" Background="#E9E5DE" Foreground="{StaticResource Ink}" Padding="15,8"/>
        </Grid>
        <StackPanel Grid.Row="1" Margin="0,30,0,0">
          <TextBlock Text="专注时长" FontWeight="SemiBold" Foreground="{StaticResource Ink}"/>
          <TextBlock x:Name="FocusValue" Text="25 分钟" Margin="0,6,0,2" Foreground="{StaticResource Tomato}"/>
          <Slider x:Name="FocusSlider" Minimum="5" Maximum="60" Value="25" TickFrequency="5" IsSnapToTickEnabled="True"/>
          <TextBlock Text="短休息" Margin="0,24,0,0" FontWeight="SemiBold" Foreground="{StaticResource Ink}"/>
          <TextBlock x:Name="ShortValue" Text="5 分钟" Margin="0,6,0,2" Foreground="{StaticResource Leaf}"/>
          <Slider x:Name="ShortSlider" Minimum="1" Maximum="20" Value="5" TickFrequency="1" IsSnapToTickEnabled="True"/>
          <TextBlock Text="长休息" Margin="0,24,0,0" FontWeight="SemiBold" Foreground="{StaticResource Ink}"/>
          <TextBlock x:Name="LongValue" Text="15 分钟" Margin="0,6,0,2" Foreground="{StaticResource Leaf}"/>
          <Slider x:Name="LongSlider" Minimum="5" Maximum="40" Value="15" TickFrequency="5" IsSnapToTickEnabled="True"/>
          <CheckBox x:Name="AutoStartCheck" Content="自动开始下一阶段" Margin="0,30,0,0" Foreground="{StaticResource Ink}" FontSize="14"/>
          <CheckBox x:Name="SoundCheck" Content="阶段结束时提醒" Margin="0,14,0,0" Foreground="{StaticResource Ink}" FontSize="14" IsChecked="True"/>
        </StackPanel>
        <TextBlock Grid.Row="2" Text="设置会保留到下次打开" HorizontalAlignment="Center" Foreground="{StaticResource Muted}" FontSize="12"/>
      </Grid>
    </Border>
  </Grid>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)
if ($AppIconPath -and (Test-Path -LiteralPath $AppIconPath)) {
  try { $window.Icon = [Windows.Media.Imaging.BitmapFrame]::Create([Uri]::new($AppIconPath)) } catch { }
}

$names = @('SettingsButton','FocusMode','ShortMode','LongMode','ProgressArc','ModeLabel','TimeText','SessionLabel','TaskBox','ResetButton','StartButton','SkipButton','CompletedText','TotalFocusText','SettingsPanel','CloseSettings','FocusValue','FocusSlider','ShortValue','ShortSlider','LongValue','LongSlider','AutoStartCheck','SoundCheck')
foreach ($name in $names) { Set-Variable -Name $name -Value $window.FindName($name) }

$script:mode = 'focus'
$script:running = $false
$script:remaining = 25 * 60
$script:duration = 25 * 60
$script:completed = 0
$script:totalFocusMinutes = 0
$script:settingsPath = Join-Path $env:LOCALAPPDATA 'TomatoFocus\settings.json'

function Get-ModeMinutes {
  param([string]$which)
  switch ($which) {
    'focus' { return [int]$FocusSlider.Value }
    'short' { return [int]$ShortSlider.Value }
    'long'  { return [int]$LongSlider.Value }
  }
}

function Save-Settings {
  $folder = Split-Path $script:settingsPath
  if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force | Out-Null }
  @{
    focus = [int]$FocusSlider.Value; short = [int]$ShortSlider.Value; long = [int]$LongSlider.Value
    autoStart = [bool]$AutoStartCheck.IsChecked; sound = [bool]$SoundCheck.IsChecked
  } | ConvertTo-Json | Set-Content -Path $script:settingsPath -Encoding UTF8
}

function Load-Settings {
  if (-not (Test-Path $script:settingsPath)) { return }
  try {
    $saved = Get-Content $script:settingsPath -Raw | ConvertFrom-Json
    $FocusSlider.Value = $saved.focus
    $ShortSlider.Value = $saved.short
    $LongSlider.Value = $saved.long
    $AutoStartCheck.IsChecked = [bool]$saved.autoStart
    $SoundCheck.IsChecked = [bool]$saved.sound
  } catch { }
}

function Update-Arc {
  $ratio = if ($script:duration -gt 0) { 1 - ($script:remaining / $script:duration) } else { 0 }
  $ratio = [Math]::Max(0, [Math]::Min(0.9999, $ratio))
  if ($ratio -le 0) { $ProgressArc.Data = $null; return }
  $angle = 360 * $ratio
  $r = 148.5
  $cx = 155; $cy = 155
  $startX = $cx; $startY = $cy - $r
  $rad = ($angle - 90) * [Math]::PI / 180
  $endX = $cx + $r * [Math]::Cos($rad)
  $endY = $cy + $r * [Math]::Sin($rad)
  $large = if ($angle -gt 180) { 1 } else { 0 }
  $geometry = "M $startX,$startY A $r,$r 0 $large 1 $endX,$endY"
  $ProgressArc.Data = [Windows.Media.Geometry]::Parse($geometry)
}

function Update-Display {
  $minutes = [Math]::Floor($script:remaining / 60)
  $seconds = $script:remaining % 60
  $TimeText.Text = '{0:00}:{1:00}' -f $minutes, $seconds
  $window.Title = if ($script:running) { "$($TimeText.Text) · 番茄" } else { '番茄 · 专注计时器' }
  $StartButton.Content = if ($script:running) { '暂停' } elseif ($script:remaining -lt $script:duration) { '继续' } elseif ($script:mode -eq 'focus') { '开始专注' } else { '开始休息' }
  $SessionLabel.Text = if ($script:mode -eq 'focus') { "第 $($script:completed + 1) 个番茄" } else { '放松一下，慢慢呼吸' }
  $CompletedText.Text = " $($script:completed) 个番茄"
  $TotalFocusText.Text = "专注 $($script:totalFocusMinutes) 分钟"
  Update-Arc
}

function Set-Mode {
  param([string]$newMode)
  $script:mode = $newMode
  $script:running = $false
  $timer.Stop()
  $script:duration = (Get-ModeMinutes $newMode) * 60
  $script:remaining = $script:duration
  foreach ($button in @($FocusMode, $ShortMode, $LongMode)) { $button.Background = [Windows.Media.Brushes]::Transparent; $button.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom('#75827D') }
  switch ($newMode) {
    'focus' { $FocusMode.Background = [Windows.Media.Brushes]::White; $FocusMode.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom('#E45B4D'); $ModeLabel.Text = '专注时间'; $ProgressArc.Stroke = [Windows.Media.BrushConverter]::new().ConvertFrom('#E45B4D') }
    'short' { $ShortMode.Background = [Windows.Media.Brushes]::White; $ShortMode.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom('#3E7865'); $ModeLabel.Text = '短休息'; $ProgressArc.Stroke = [Windows.Media.BrushConverter]::new().ConvertFrom('#3E7865') }
    'long'  { $LongMode.Background = [Windows.Media.Brushes]::White; $LongMode.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom('#3E7865'); $ModeLabel.Text = '长休息'; $ProgressArc.Stroke = [Windows.Media.BrushConverter]::new().ConvertFrom('#3E7865') }
  }
  Update-Display
}

function Show-Notification {
  param([string]$title, [string]$message)
  if (-not $SoundCheck.IsChecked) { return }
  [System.Media.SystemSounds]::Asterisk.Play()
  $notify = New-Object System.Windows.Forms.NotifyIcon
  $notify.Icon = [System.Drawing.SystemIcons]::Information
  $notify.Visible = $true
  $notify.BalloonTipTitle = $title
  $notify.BalloonTipText = $message
  $notify.ShowBalloonTip(5000)
  $cleanup = New-Object Windows.Threading.DispatcherTimer
  $cleanup.Interval = [TimeSpan]::FromSeconds(6)
  $cleanup.Add_Tick({ $notify.Dispose(); $this.Stop() })
  $cleanup.Start()
}

function Complete-Stage {
  $script:running = $false
  $timer.Stop()
  if ($script:mode -eq 'focus') {
    $script:completed++
    $script:totalFocusMinutes += Get-ModeMinutes 'focus'
    Show-Notification '专注完成' '做得好。现在休息一下吧。'
    $nextMode = if (($script:completed % 4) -eq 0) { 'long' } else { 'short' }
  } else {
    Show-Notification '休息结束' '状态不错，开始下一轮专注吧。'
    $nextMode = 'focus'
  }
  Set-Mode $nextMode
  if ($AutoStartCheck.IsChecked) { $script:running = $true; $timer.Start(); Update-Display }
}

$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$timer.Add_Tick({
  if ($script:remaining -gt 0) { $script:remaining--; Update-Display }
  if ($script:remaining -le 0) { Complete-Stage }
})

$StartButton.Add_Click({
  $script:running = -not $script:running
  if ($script:running) { $timer.Start() } else { $timer.Stop() }
  Update-Display
})
$ResetButton.Add_Click({ Set-Mode $script:mode })
$SkipButton.Add_Click({ Complete-Stage })
$FocusMode.Add_Click({ Set-Mode 'focus' })
$ShortMode.Add_Click({ Set-Mode 'short' })
$LongMode.Add_Click({ Set-Mode 'long' })
$SettingsButton.Add_Click({ $SettingsPanel.Visibility = 'Visible' })
$CloseSettings.Add_Click({ Save-Settings; $SettingsPanel.Visibility = 'Collapsed'; Set-Mode $script:mode })

$FocusSlider.Add_ValueChanged({ $FocusValue.Text = "$([int]$FocusSlider.Value) 分钟" })
$ShortSlider.Add_ValueChanged({ $ShortValue.Text = "$([int]$ShortSlider.Value) 分钟" })
$LongSlider.Add_ValueChanged({ $LongValue.Text = "$([int]$LongSlider.Value) 分钟" })
$TaskBox.Add_GotFocus({ if ($TaskBox.Text -eq '准备专注的事情…') { $TaskBox.Text = ''; $TaskBox.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom('#24332F') } })
$TaskBox.Add_LostFocus({ if ([string]::IsNullOrWhiteSpace($TaskBox.Text)) { $TaskBox.Text = '准备专注的事情…'; $TaskBox.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom('#75827D') } })
$window.Add_Closing({ Save-Settings })

Load-Settings
Set-Mode 'focus'
$window.ShowDialog() | Out-Null
