   <# #Create scheduled task
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy bypass -WindowStyle Hidden -File $dest\Hybrid-Notifications.ps1"
    #Create the scheduled tsak trigger
    $timespan = New-Timespan -minutes 5
    #$triggers = @()

    $trigger = New-ScheduledTaskTrigger -AtLogOn -RepetitionInterval $timespan -RepetitionDuration ([System.TimeSpan]::MaxValue)

    # Register the scheduled task
    Register-ScheduledTask -User SYSTEM -Action $action -Trigger $trigger -TaskName "Hybrid-Notifications" -Description "Hybrid-Notifications" -Force
    #>
    $dest = "$($env:ProgramData)\Dell\Hybrid-Notifications"
        #Create scheduled task
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy bypass -WindowStyle Hidden -File $dest\Hybrid-Notifications.ps1"
    #Create the scheduled tsak trigger
    $timespan = New-Timespan -minutes 5
    $triggers = @()
   # $triggers += New-ScheduledTaskTrigger -Daily -At 9am
    $triggers += New-ScheduledTaskTrigger -Once -At 1am -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1)
   # $triggers += New-ScheduledTaskTrigger -AtStartup -RandomDelay $timespan
    # Register the scheduled task
    Register-ScheduledTask -User SYSTEM -Action $action -Trigger $triggers -TaskName "Hybrid-Notifications" -Description "Hybrid-Notifications" -Force
    Write-Host "Scheduled task created."
