# Copyright (c) 2026 Brendigo. MIT.
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
$root=Join-Path $env:LOCALAPPDATA 'BrenOS'
[xml]$xaml=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="BrenOS Control Center" Width="760" Height="510" MinWidth="700" MinHeight="460" WindowStartupLocation="CenterScreen" Background="#17273B" Foreground="#EDF5FF" FontFamily="Segoe UI" ResizeMode="CanResize">
 <Grid Margin="30">
  <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
  <StackPanel>
   <TextBlock Text="BrenOS" FontSize="36" FontWeight="SemiBold" Foreground="#F6FAFF"/>
   <TextBlock Text="FLOW  /  FOCUS  /  FURTHER" Foreground="#8BD6FA" Margin="2,5,0,0" FontSize="12"/>
  </StackPanel>
  <Border Grid.Row="1" Margin="0,30,0,20" Background="#233C55" CornerRadius="18" Padding="25">
   <StackPanel>
    <TextBlock Text="Personalizacija" FontWeight="SemiBold" FontSize="23"/>
    <TextBlock Text="Odaberi stil pozadine. Primjena ne mijenja sistemske datoteke." Foreground="#B9CBDF" Margin="0,7,0,20"/>
    <StackPanel Orientation="Horizontal">
     <Button Name="Flow" Content="Flow" Width="130" Height="45" Margin="0,0,12,0" Background="#3489DD" Foreground="White" BorderThickness="0"/>
     <Button Name="Dawn" Content="Dawn" Width="130" Height="45" Margin="0,0,12,0" Background="#3489DD" Foreground="White" BorderThickness="0"/>
     <Button Name="Midnight" Content="Midnight" Width="130" Height="45" Background="#3489DD" Foreground="White" BorderThickness="0"/>
    </StackPanel>
    <Button Name="Settings" Content="Otvori Windows postavke personalizacije" HorizontalAlignment="Left" Margin="0,28,0,0" Padding="15,10" Background="#2E4E6E" Foreground="White" BorderThickness="0"/>
   </StackPanel>
  </Border>
  <DockPanel Grid.Row="2">
   <Button Name="Restore" Content="Vrati prethodni izgled" Width="190" Height="42" Background="#344961" Foreground="White" BorderThickness="0" DockPanel.Dock="Right"/>
   <TextBlock Text="BrenOS 1.0  •  by Brendigo" Foreground="#A4B9CD" VerticalAlignment="Center"/>
  </DockPanel>
 </Grid>
</Window>
'@
$reader=New-Object System.Xml.XmlNodeReader $xaml
$window=[Windows.Markup.XamlReader]::Load($reader)
foreach ($style in @('Flow','Dawn','Midnight')) {
    $button=$window.FindName($style)
    $name=$style
    $button.Tag=$name
    $button.Add_Click({
        param($sender,$eventArgs)
        $styleName=[string]$sender.Tag
        & (Join-Path $root 'scripts\Install-BrenOS.ps1') -Wallpaper $styleName
        [System.Windows.MessageBox]::Show("Primijenjena pozadina: $styleName",'BrenOS') | Out-Null
    })
}
$window.FindName('Settings').Add_Click({Start-Process 'ms-settings:personalization'})
$window.FindName('Restore').Add_Click({
  $result=[System.Windows.MessageBox]::Show('Vratiti spremljene postavke prije BrenOS instalacije?','BrenOS','YesNo','Question')
  if ($result -eq 'Yes') {
    & (Join-Path $root 'scripts\Restore-BrenOS.ps1')
    [System.Windows.MessageBox]::Show('Prethodne postavke su vracene.','BrenOS') | Out-Null
    $window.Close()
  }
})
$window.ShowDialog() | Out-Null
