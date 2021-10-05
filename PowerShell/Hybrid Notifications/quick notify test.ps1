$dest = "$($env:ProgramData)\Dell\Hybrid-Notifications"
if (-not (Test-Path $dest))
{
    mkdir $dest
}
Start-Transcript "$dest\quick notify.log" -Append

#Functions

Function Write-ToastReboot{
    #Build out registry for custom action for rebooting the device via the action button
    try {
        #HKCR
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
        $ToastProtocol = get-item 'HKCR:\ToastReboot' -erroraction 'silentlycontinue'
        if (!$ToastProtocol) {
            New-item 'HKCR:\ToastReboot' -force
            set-itemproperty 'HKCR:\ToastReboot' -name '(DEFAULT)' -value 'url:ToastReboot' -force
            set-itemproperty 'HKCR:\ToastReboot' -name 'URL Protocol' -value '' -force
            new-itemproperty -path 'HKCR:\ToastReboot' -propertytype dword -name 'EditFlags' -value 2162688
            New-item 'HKCR:\ToastReboot\Shell\Open\command' -force
            set-itemproperty 'HKCR:\ToastReboot\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\System32\shutdown.exe -r -t 00' -force
        }

    }
    catch {
        Write-Host "Failed to create the ToastReboot custom protocol in HKCR. Action button might not work"
        $ErrorMessage = $_.Exception.Message
        Write-Host "Error message: $ErrorMessage"
    }
}

function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText,
        $RestartBoolean
    )
    If (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM") {
        


        #Created Scheduled Task to run as logged on user
        #Set Unique GUID for the Toast
        If (!($ToastGUID)) {
            $ToastGUID = ([guid]::NewGuid()).ToString().ToUpper()
        }
        $Task_TimeToRun = (Get-Date).AddSeconds(30).ToString('s')
        $Task_Expiry = (Get-Date).AddSeconds(120).ToString('s')
        $Task_Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File $dest\Hybrid-Notifications.ps1 -paramtitle ""$ToastTitle"" -paramtext ""$ToastText"""
        
        $Task_Trigger = New-ScheduledTaskTrigger -Once -At $Task_TimeToRun
        $Task_Trigger.EndBoundary = $Task_Expiry
        $Task_Principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -RunLevel Limited
        $Task_Settings = New-ScheduledTaskSettingsSet -Compatibility V1 -DeleteExpiredTaskAfter (New-TimeSpan -Seconds 600) -AllowStartIfOnBatteries
        $New_Task = New-ScheduledTask -Description "User_Toast_Notification_$ToastGUID Task for user notification. Title: $($ToastTitle) :: Text:$($ToastText) " -Action $Task_Action -Principal $Task_Principal -Trigger $Task_Trigger -Settings $Task_Settings
        Write-Host "Attempting to create user scheduled task with title: $ToastTitle and text: $ToastText"
        Register-ScheduledTask -TaskName "User_Toast_Notification_$ToastGUID" -InputObject $New_Task
    }else{
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

        $RawXml = [xml] $Template.GetXml()
        ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
        ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null
        # $actions = $RawXml.CreateElement("actions")
        # Write-Host $actions.OuterXml
        If($RestartBoolean){
            $actions = $RawXml.CreateElement("actions")
            $action1 = $RawXml.CreateElement("action")
            $button1Type = $RawXml.CreateAttribute("activationType")
            $button1Type.Value = "protocol"
            $button1Arguments = $RawXml.CreateAttribute("arguments")
            $button1Arguments.Value = "ToastReboot:"
            #$button1Arguments.Value = "https://www.dell.com"
            #$button1Arguments.Value = "C:\ProgramData\Dell\Hybrid-Notifications\runme.cmd"
            $button1Content = $RawXml.CreateAttribute("content")
            $button1Content.Value = "Restart"

            $action2 = $RawXml.CreateElement("action")
            $button2Type = $RawXml.CreateAttribute("activationType")
            $button2Type.Value = "system"
            $button2Arguments = $RawXml.CreateAttribute("arguments")
            $button2Arguments.Value = "dismiss"
            $button2Content = $RawXml.CreateAttribute("content")
            $button2Content.Value = "Dismiss"

            $action1.Attributes.Append($button1Type) > $null
            $action1.Attributes.Append($button1Arguments) > $null
            $action1.Attributes.Append($button1Content) > $null

            $action2.Attributes.Append($button2Type) > $null
            $action2.Attributes.Append($button2Arguments) > $null
            $action2.Attributes.Append($button2Content) > $null

            $actions.AppendChild($action1) > $null
            $actions.AppendChild($action2) > $null
            $RawXml.DocumentElement.AppendChild($actions) > $null
            Write-ToastReboot
        }
        Write-Host $RawXml.OuterXml
        $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $SerializedXml.LoadXml($RawXml.OuterXml)
       

        $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
        $Toast.Tag = "PowerShell"
        $Toast.Group = "PowerShell"
        $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(4)

        $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
        $Notifier.Show($Toast);
    }
}

function Show-Notification2 {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )
    If (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM") {
        


        #Created Scheduled Task to run as logged on user
        #Set Unique GUID for the Toast
        If (!($ToastGUID)) {
            $ToastGUID = ([guid]::NewGuid()).ToString().ToUpper()
        }
        $Task_TimeToRun = (Get-Date).AddSeconds(30).ToString('s')
        $Task_Expiry = (Get-Date).AddSeconds(120).ToString('s')
        $Task_Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File $dest\Hybrid-Notifications.ps1 -paramtitle ""$ToastTitle"" -paramtext ""$ToastText"""
        
        $Task_Trigger = New-ScheduledTaskTrigger -Once -At $Task_TimeToRun
        $Task_Trigger.EndBoundary = $Task_Expiry
        $Task_Principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -RunLevel Limited
        $Task_Settings = New-ScheduledTaskSettingsSet -Compatibility V1 -DeleteExpiredTaskAfter (New-TimeSpan -Seconds 600) -AllowStartIfOnBatteries
        $New_Task = New-ScheduledTask -Description "User_Toast_Notification_$ToastGUID Task for user notification. Title: $($ToastTitle) :: Text:$($ToastText) " -Action $Task_Action -Principal $Task_Principal -Trigger $Task_Trigger -Settings $Task_Settings
        Write-Host "Attempting to create user scheduled task with title: $ToastTitle and text: $ToastText"
        Register-ScheduledTask -TaskName "User_Toast_Notification_$ToastGUID" -InputObject $New_Task
    }else{
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

        [xml]$RawXml = @"
        <toast>
    <visual>
    <binding template="ToastText02">
        <text>$ToastTitle</text>
        <text>$ToastText</text>
    </binding>
    </visual>
    <actions>
        <action activationType="protocol" arguments="Action1" content="ActionButton1Content" />
    </actions>
</toast>
"@
        
        Write-Host $RawXml.OuterXml
        $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $SerializedXml.LoadXml($RawXml.OuterXml)
       

        $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
        $Toast.Tag = "PowerShell"
        $Toast.Group = "PowerShell"
        $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(4)

        $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
        $Notifier.Show($Toast);
    }
}

Show-Notification -ToastTitle "Hybrid Join Notifications" -ToastText "$env:computername has not yet completed hybrid join process, functionality will be reduced"
Start-Sleep -Seconds 10
Show-Notification -ToastTitle "Hybrid Join Notifications" -ToastText "Hybrid join process complete on $env:computername, a restart is recommended" -RestartBoolean True
#Start-Sleep -seconds 5
#Show-Notification2 -ToastTitle "Demo Title 2" -ToastText "Demonstration text blah blah 2"
Stop-Transcript