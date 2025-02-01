;Aether 2024 
; Contains 
; win+ q to rightclick 
; altshift+mouse to volume 
; win + space to media control 
; hjkl to arrow keys 
; win + [] to brighness 
; toggle on/ off title bar
; Share with win+s
; Double-clicking the middle mouse button (MButton) sends the space bar.
; middle click twice to plaay /

;mouse without borders

SetTimer, CheckMousePosition, 100  ; Check the mouse position every 100 ms

CoordMode, Mouse, Screen  ; Use screen coordinates for the mouse position

timeout := 950  ; Time threshold in ms
lastMoveTime := 0  ; Variable to store the time when the mouse was last at the desired X or Y coordinates
isInPosition := false  ; Track if the mouse is currently at the desired position

CheckMousePosition:
MouseGetPos, mouseX, mouseY  ; Get current mouse position

; Check if Control is held down
if GetKeyState("Control", "P")
{
    ; Check if mouse is near the edge of the screen (edge defined as 10px from each side)
    if (mouseX <= 10 or mouseX >= A_ScreenWidth - 10 or mouseY <= 10 or mouseY >= A_ScreenHeight - 10)
    {
        ; For X = 2559 (send Ctrl+Win+Right)
        if (mouseX = 2559)
        {
            if (!isInPosition)  ; If it wasn't already detected as being in position
            {
                lastMoveTime := A_TickCount  ; Store the time when the mouse enters the position
                isInPosition := true  ; Set flag to true
            }
            else if (A_TickCount - lastMoveTime >= timeout)  ; If the mouse stays in position for more than timeout ms
            {
                Send, ^#{Right}  ; Send Ctrl+Win+Right key combination
                isInPosition := false  ; Reset the flag
            }
        }

        ; For X = 0 (send Ctrl+Win+Left)
        else if (mouseX = 0)
        {
            if (!isInPosition)  ; If it wasn't already detected as being in position
            {
                lastMoveTime := A_TickCount  ; Store the time when the mouse enters the position
                isInPosition := true  ; Set flag to true
            }
            else if (A_TickCount - lastMoveTime >= timeout)  ; If the mouse stays in position for more than timeout ms
            {
                Send, ^#{Left}  ; Send Ctrl+Win+Left key combination
                isInPosition := false  ; Reset the flag
            }
        }

        ; For Y = 1359 (send Win+Tab)
        ; else if (mouseY = 0)
        ; {
        ;     if (!isInPosition)  ; If it wasn't already detected as being in position
        ;     {
        ;         lastMoveTime := A_TickCount  ; Store the time when the mouse enters the position
        ;         isInPosition := true  ; Set flag to true
        ;     }
        ;     else if (A_TickCount - lastMoveTime >= timeout)  ; If the mouse stays in position for more than timeout ms
        ;     {
        ;         Send, #{Tab}  ; Send Win+Tab key combination
        ;         isInPosition := false  ; Reset the flag
        ;     }
        ; }
        ; else  ; If the mouse is not at any of the desired X or Y coordinates
        ; {
        ;     isInPosition := false  ; Reset the flag
        ; }

    }
}

return

; Define variables for detecting double-press
EscPressTime := 0
DoublePressThreshold := 400 ; Time in milliseconds

; Hotkey for Esc key
~Esc::
    CurrentTime := A_TickCount
    if (CurrentTime - EscPressTime < DoublePressThreshold)
    {
        ; Perform Undo (Ctrl+Z)
        Send, ^z
        EscPressTime := 0 ; Reset to avoid triple press triggering
    }
    else
    {
        EscPressTime := CurrentTime
    }
return  

; ~LWin:: return  ; Prevent default behavior of LWin key

#WheelUp::  ; Win + Scroll Wheel Up
if (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))  ; Check if any Windows key is held down
    SendInput ^#{Right}  ; Send Win + Ctrl + Right
return

#WheelDown::  ; Win + Scroll Wheel Down
if (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))  ; Check if any Windows key is held down
    SendInput ^#{Left}  ; Send Win + Ctrl + Left
return

#if 


~MButton::
    if (A_PriorHotkey = "~MButton" && A_TimeSincePriorHotkey < 400) ; Adjust timing as needed
    {
        Send, {Space}
        return
    }
return


#q::
    Send, +{F10}
return
    !+WheelUp:: Send { Volume_Up 2 } 		; #Winkey + Scroll mouse wheel up = increase volume
    !+WheelDown:: Send { Volume_Down 2 } 	; #Winkey + Scroll mouse wheel down = decrease volume
    !+MButton::Volume_Mute	
return

!+]:: 
    Send { Volume_Up 2 } ;
return
!+[:: 
    Send { Volume_Down 2 } ;
return
; AutoHotkey Media Keys
#Space:: 
    Send { Media_Play_Pause }
return
; Borderless Windows
^#h::
    WinGet, style, Style, A
    if (style & 0xC00000)  ; Check if the caption is currently enabled
    {
        WinSet, Style, -0xC00000, A  ; Remove caption
        WinSet, ExStyle, -0x00000100, A ; Remove the tiny frame or "window edge" at the top
    }
    else {
        WinSet, Style, +0xC00000, A  ; Add caption
        WinSet, ExStyle, +0x00000100, A ; Restore the frame or "window edge"
    }
    ; WinMove, A, , 0, 0, %A_ScreenWidth%, %A_ScreenHeight% ; Optional: Resize to fullscreen
    return

; Brightness Controls

#[:: Brightness("-5") ; Reduces brightness by 5%
#]:: Brightness("+5") ; Increases brightness by 5%

    Brightness(Offset) {
        static wmi := ComObjGet("winmgmts:\\.\root\WMI")
        , last := wmi.ExecQuery("SELECT * FROM WmiMonitorBrightness").ItemIndex(0).CurrentBrightness
        level := Min(100, Max(1, last + Offset))
        if (level != last) {
            last := level
            wmi.ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods").ItemIndex(0).WmiSetBrightness(0, level)
        }
    }


; Arrow Keys
!h:: Send, { Left }
!j:: Send, { Down }
!k:: Send, { Up }
!l:: Send, { Right }
return 



*CapsLock::
    Send {Blind}{Ctrl Down}
    cDown := A_TickCount
Return

*CapsLock up::
    ; If ((A_TickCount-cDown)<200)  ; Modify press time as needed (milliseconds)
    ;     Send {Blind}{Ctrl Up}{CapsLock}
    ; Else
        Send {Blind}{Ctrl Up}
Return

^CapsLock::
    SetCapsLockState, % GetKeyState("CapsLock", "T") ? "Off" : "On"
    Return

+CapsLock::
    SetCapsLockState, % GetKeyState("CapsLock", "T") ? "Off" : "On"
    Return



!q::
    Send {delete}

; Alt + Caps Lock sends Enter
!CapsLock::
    Send {Enter}
Return



