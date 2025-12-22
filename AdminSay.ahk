; AdminSay.ahk
; Sends an admin broadcast in Icarus via in-game chat

#NoEnv
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%

Message := %1%

; Bring Icarus window to foreground
IfWinExist, Icarus
{
    WinActivate
    Sleep, 500

    ; Open chat
    Send, {Enter}
    Sleep, 200

    ; Send admin message
    Send, /AdminSay %Message%
    Sleep, 200
    Send, {Enter}
}
