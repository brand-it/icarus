$ServiceName = "IcarusServer"
$AhkPath     = "C:\Program Files\AutoHotkey\AutoHotkey.exe"
$AhkScript   = "C:\Users\newdark\icarus\AdminSay.ahk"

function AdminSay($msg) {
    Start-Process -FilePath $AhkPath `
        -ArgumentList "`"$AhkScript`" `"$msg`"" `
        -NoNewWindow
}

# Warning sequence
AdminSay "⚠️ SERVER RESTART IN 15 MINUTES — scheduled maintenance"
Start-Sleep -Seconds (10 * 60)

AdminSay "⚠️ SERVER RESTART IN 5 MINUTES — please return to safety"
Start-Sleep -Seconds (4 * 60)

AdminSay "⚠️ SERVER RESTART IN 60 SECONDS — logout to avoid issues"
Start-Sleep -Seconds 60

# Final notice
AdminSay "🛑 SERVER RESTARTING NOW"

# Restart the server
Restart-Service -Name $ServiceName -Force
