;Aether 2024 

;MOUSE WITHOUT BORDERS 

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
            if (!isInPosition)  
            {
                lastMoveTime := A_TickCount 
                isInPosition := true 
            }
            else if (A_TickCount - lastMoveTime >= timeout)  
            {
                Send, ^#{Right}  
                
                isInPosition := false  
            }
        }

        ; For X = 0 (send Ctrl+Win+Left)
        else if (mouseX = 0)
        {
            if (!isInPosition)  
            {
                lastMoveTime := A_TickCount 
                isInPosition := true  
            else if (A_TickCount - lastMoveTime >= timeout)  
            {
                Send, ^#{Left}  
                isInPosition := false  
            }
        }




    }
}

return

; DOUBLE TAP ESCAPE TO UNDO 
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

; DOUBLE TAP MIDDLE MOUSE TO PLAY PAUSE [SENDS SPACE]

~MButton::
    if (A_PriorHotkey = "~MButton" && A_TimeSincePriorHotkey < 400) 
    {
        Send, {Space}
        return
    }
return

; RIGHT CLICK CONTEXT MENU

#q::
    Send, +{F10}
return
    !+WheelUp:: Send { Volume_Up 2 } 		; #Winkey + Scroll mouse wheel up = increase volume
    !+WheelDown:: Send { Volume_Down 2 } 	; #Winkey + Scroll mouse wheel down = decrease volume
    !+MButton::Volume_Mute	
return


; VOLUME CONTROLS 
!+]:: 
    Send { Volume_Up 2 } ;
return
!+[:: 
    Send { Volume_Down 2 } ;
return
; MEDIA CONTROL 
#Space:: 
    Send { Media_Play_Pause }
return
; TOGGLE TITLEBAR ON/ OFF
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
    return

; BRIGHTNESS CONTROL

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


; ARROW KEYS 
!h:: Send, { Left }
!j:: Send, { Down }
!k:: Send, { Up }
!l:: Send, { Right }
return 


; CAPS TO CONTROL 
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

; CAPS LOCK TOGGLE 
^CapsLock::
    SetCapsLockState, % GetKeyState("CapsLock", "T") ? "Off" : "On"
    Return

+CapsLock::
    SetCapsLockState, % GetKeyState("CapsLock", "T") ? "Off" : "On"
    Return


; WIND Q TO DELETE
!q::
    Send {delete}

; ALT CAPS TO ENTER 
!CapsLock::
    Send {Enter}
Return



