; LKD70s ARK: All in one
; This project and all files associated with it are licensed under the MIT License.
; A copy of this license can be found in the parent directory of the project or at
; the following link: https://github.com/lkd70/ark_All_In_One/blob/main/LICENSE

#MaxThreadsPerHotkey 2
;CoordMode("ToolTip", "Screen")

global invColour := "0x008AA9"
global RemoteSearch := ScaleCoords(1300, 180)
global RemoteDrop := ScaleCoords(1530, 190)
global RemoteTransferAll := ScaleCoords(1480, 190)
global LocalSearch := ScaleCoords(175, 180)
global LocalTransferAll := ScaleCoords(350, 190)
global InvPixel := ScaleCoords(1815, 33)
global implant := ScaleCoords(160, 280)
global toggle := 0
global F_Mode := 1
global F_Modes := ["Off", "Feed Meat", "Feed Berries", "Gather Crops"]

runMacro("Init",, 10)

For f in [ 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12 ] {
    boundFunc := Func("runMacro").bind("F" . f)
    Hotkey("$F" . f, boundFunc)
}

RCtrl:: Send("{w " . ( GetKeyState("w") ? "Up}" : "Down}"))
RShift:: Send("{Shift " . ( GetKeyState("Shift") ? "Up}" : "Down}"))
~F:: runMacro("Magic")
$F9:: Reload()

Init_Macro() {
    ToolTip("Setting gamma to default...", 0, 0)
    Sleep(1000)
    send("{tab}")
    Sleep(100)
    send("gamma")
    Sleep(100)
    send("{enter}")
    ToolTip()
}

F1_Macro() {
    openInventory()
    transferFromInventory("hide")
    dropFromRemote([ "i", "rr", "p", "dust" ])
	Send("{Esc}")
}

F2_Macro() {
    openInventory()
    dropFromRemote([ "w", "c", "s" ])
	Send("{Esc}")
}

F3_Macro() {
    openInventory()
    dropFromRemote([ "st", "od", "th", "de", "an", "at" ])
    Send("{Esc}")
}

F4_Macro() {
	Click("Down Right")
	Send("{E Down}")
	Send("{E Up}")
	Sleep(50)
	Click("Up Right")
}

F5_Macro() {
    toggle := !toggle
    loop {
        If (!toggle)
            break
        Click()
        Sleep(50)
    }
}

F6_Macro() {
    toggle := !toggle
    loop 60 {
        if (!toggle)
            break
        transferFromInventory()
        MouseMove(implant.x + 500, implant.y, 1)
        Sleep(200)
        Send("o")
        Sleep(200)
        MouseMove(implant.x + 400, implant.y, 1)
        Sleep(200)
        Send("o")
        MouseMove(implant.x + 300, implant.y, 1)
        Sleep(200)
        Send("o")
        MouseMove(implant.x + 200, implant.y, 1)
        Sleep(200)
        Send("o")
        MouseMove(implant.x + 100, implant.y, 1)
        Sleep(200)
        Send("o")
        Sleep(100)
    }
}

F7_Macro() {
    F_Mode := F_Mode + 1
    if (F_Mode > F_Modes.Length) {
        F_Mode := 1
        ToolTip("Mode: Off", 0, 0)
        Sleep(1000)
        ToolTip()
    } else {
        ToolTip("Mode: " . F_Modes[F_Mode], 0, 0)
    }

}

F8_Macro() {
    toggle := !toggle
    Counter := 0
    loop {
            if (!toggle)
                break
            Counter := Counter + 1
            Send("F")
            Sleep(500)
            Send("F")
            ToolTip("Slots gained: " . Counter, 0,0)
            Sleep(500)
        }
    Sleep(5000)
    ToolTip()
}

F10_Macro() {
    
}

Magic_1_Macro() {
    ToolTip("Feeding meat...", 0, 0)
    WaitColour(InvPixel.x, InvPixel.y, invColour)
    Colour := PixelGetColor(InvPixel.x, InvPixel.y)
    if (Colour = invColour) {
        transferFromInventory("oil")
        transferFromInventory("raw", ,true)
        Send("{Esc}")
    }
}

Magic_2_Macro() {
    ToolTip("Feeding berries...", 0, 0)
    WaitColour(InvPixel.x, InvPixel.y, invColour)
    Colour := PixelGetColor(InvPixel.x, InvPixel.y)
    if (Colour = invColour) {
        transferFromInventory("berry", ,true)
        Send("{Esc}")
    }
}

Magic_3_Macro() {
    ToolTip("Gathering Crops...", 0, 0)
    WaitColour(InvPixel.x, InvPixel.y, invColour)
    Colour := PixelGetColor(InvPixel.x, InvPixel.y)
    if (Colour = invColour) {
        transferFromInventory()
        transferFromInventory(,, true)
        Send("{Esc}")
    }
}

Magic_Macro() {
    funcName := "Magic_" . (F_Mode - 1) . "_Macro"
    run := Func(funcName)
    if (IsObject(run)) {
        Sleep(100)
        %run%()
        ToolTip("Mode: " . F_Modes[F_Mode] , 0, 0)
    }
}

runMacro(callback, exec := "ahk_exe ShooterGame.exe", waitTimeout := 0, exitOnTimeout := true) {
    method := (waitTimeout = 0) ? Func("WinActive") : Func("WinWaitActive").Bind(,,waitTimeout)
    if (InStr(exec, "$F")) {
        exec := "ahk_exe ShooterGame.exe"
    }
    if(method.Call(exec)) {
        run := Func(callback . "_Macro")
        if (run) 
            %run%()
    } else {
        if (waitTimeout = 0) {
            Send("{" . callback . "}")
        } Else if (exitOnTimeout) {
            MsgBox("Attempted to wait " . waitTimeout . " seconds - '" . exec . "'' not started, exiting", "not loaded")
            Exit(1)
        }
    }
}

openInventory(localInventory := false, maxTries := 1000) {
    res := WaitColour(InvPixel.x, InvPixel.y, invColour, 1)
    if (res == true)
        return true
    Send(localInventory ? "i" : "f")
    res := WaitColour(InvPixel.x, InvPixel.y, invColour, maxTries)
    return res
}

transferFromInventory(items := "", delay := 500, isLocalInventory := false) {
    if (items) {
        if (IsObject(items)) {
            for item in items {
                transferFromInventory(item, delay, isLocalInventory)
            }
            Return
        }
        MouseMove(isLocalInventory ? LocalSearch.x : RemoteSearch.y, isLocalInventory ? LocalSearch.y : RemoteSearch.y, 1)
        Click()
        Sleep(50)
        Send(items)
        Sleep(50)
    }
    MouseMove(isLocalInventory ? LocalTransferAll.x : RemoteTransferAll.x, isLocalInventory ? LocalTransferAll.y : RemoteTransferAll.y, 1)
    click()
    sleep(delay)
}

dropFromRemote(items := "", delay := 500) {
    if (items) {
        if (IsObject(items)) {
            For item in items {
                dropFromRemote(item, delay)
            }
            Return
        }
        MouseMove(RemoteSearch.x, RemoteSearch.y, 1)
        Click()
        Sleep(50)
        Send(items)
        Sleep(50)
    }
    MouseMove(RemoteDrop.x, RemoteDrop.y, 1)
    Click()
    Sleep(delay)
}

WaitColour(x, y, colour, maxTries := 1000, variation := 10) {
    loop maxTries {
        if (PixelSearch(a, b, x, y, x, y, colour, variation)) {
            return True
        } else {
            Sleep(50)
        }
    }
    return False
}

ScaleCoords(x, y) {
    outx := (x / 1920) * A_ScreenWidth
    outy := (y / 1080) * A_ScreenHeight
    return {x: Floor(outx), y: Floor(outy)}
}
