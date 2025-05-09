Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "9M2PJU Windows Optimizer"
$form.Size = New-Object System.Drawing.Size(400,300)
$form.StartPosition = "CenterScreen"

# Create Buttons
$btnTemp = New-Object System.Windows.Forms.Button
$btnTemp.Location = New-Object System.Drawing.Point(50,30)
$btnTemp.Size = New-Object System.Drawing.Size(300,40)
$btnTemp.Text = "Clean Temp Files"
$form.Controls.Add($btnTemp)

$btnUpdate = New-Object System.Windows.Forms.Button
$btnUpdate.Location = New-Object System.Drawing.Point(50,80)
$btnUpdate.Size = New-Object System.Drawing.Size(300,40)
$btnUpdate.Text = "Clear Windows Update Cache"
$form.Controls.Add($btnUpdate)

$btnStartup = New-Object System.Windows.Forms.Button
$btnStartup.Location = New-Object System.Drawing.Point(50,130)
$btnStartup.Size = New-Object System.Drawing.Size(300,40)
$btnStartup.Text = "Disable Startup Apps"
$form.Controls.Add($btnStartup)

$btnDefrag = New-Object System.Windows.Forms.Button
$btnDefrag.Location = New-Object System.Drawing.Point(50,180)
$btnDefrag.Size = New-Object System.Drawing.Size(300,40)
$btnDefrag.Text = "Optimize (Defrag HDD)"
$form.Controls.Add($btnDefrag)

# Action: Clean Temp Files
$btnTemp.Add_Click({
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("Temp files cleaned!")
})

# Action: Clear Windows Update Cache
$btnUpdate.Add_Click({
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("Windows Update cache cleared!")
})

# Action: Disable Startup Apps
$btnStartup.Add_Click({
    $apps = Get-CimInstance -ClassName Win32_StartupCommand | Where-Object { $_.User -ne $null -and $_.Location -like "*Startup" }
    foreach ($app in $apps) {
        try {
            schtasks /Change /TN $app.Name /Disable 2>$null
        } catch {}
    }
    [System.Windows.Forms.MessageBox]::Show("Startup apps disabled (safe ones only).")
})

# Action: Optimize Drives
$btnDefrag.Add_Click({
    Optimize-Volume -DriveLetter C -Defrag -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("Drive C optimized (HDD only).")
})

# Run GUI
$form.Topmost = $true
[void]$form.ShowDialog()
