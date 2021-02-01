; LKD70s ARK: All in one
; This project and all files associated with it are licensed under the AGPL-3.0 License.
; A copy of this license can be found in the parent directory of the project or at
; the following link: https://github.com/lkd70/LKD_ARK_AIO/blob/master/LICENSE

#MaxThreadsPerHotkey 2
CoordMode "ToolTip", "Screen"


global ProjectName := "LKD ARK AIO"
global version := 1.4
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
global F_Modes := ["Off", "Feed Meat", "Feed Berries", "Gather Crops", "Pickup All"]

; Check release version, see if there's a newer one available
print("Checking version...")
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://raw.githubusercontent.com/lkd70/LKD_ARK_AIO/master/version.txt")
whr.Send()
whr.WaitForResponse()
version_available := Float(whr.ResponseText)
print("Current version: " . version . " Version available: " . version)
if (version_available > version) {
    Result := MsgBox("A newer version of this script is avaiable for download. Would you like to download it?",, "YesNo")
    if (Result = "Yes") {
        Run("https://github.com/lkd70/LKD_ARK_AIO/releases/latest/download/ARK_All_In_One.exe")
        ExitApp(1)
    }
}

runMacro("Init",, 10)

For f in [ 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12 ] {
    boundFunc := Func("runMacro").bind("F" . f)
    Hotkey("$F" . f, boundFunc)
}

RCtrl:: Send("{w " . ( GetKeyState("w") ? "Up}" : "Down}"))
~W & RShift:: {
	Send("{w " . ( GetKeyState("w") ? "Up}" : "Down}"))
	Send("{Shift " . ( GetKeyState("Shift") ? "Up}" : "Down}"))
}
~F:: runMacro("Magic")
$F9:: Reload()

Init_Macro() {
    print("Setting gamma to default...")
    Rest(100)
    send("{tab}")
    Rest(50)
    send("gamma")
    Rest(50)
    send("{enter}")
    print()
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
	Rest(50)
	Click("Up Right")
}

F5_Macro() {
    toggle := !toggle
    loop {
        If (!toggle)
            break
        Click()
        Rest(50)
    }
}

F6_Macro() {
    toggle := !toggle
    dropped := 0
    loop 60 {
        if (!toggle) {
            print()
            break
        }
        transferFromInventory()
        loop 5 {
            dropped := dropped + 1
            Rest(10)
            MouseMove(implant.x + ( A_Index * 100), implant.y, 1)
            Rest(100)
            Send("o")
            print("Dropped stacks: " dropped)
        }
    }
    print()
}

F7_Macro() {
    F_Mode := F_Mode + 1
    if (F_Mode > F_Modes.Length) {
        F_Mode := 1
        print("Mode: Off (F Modes:" F_Modes.Length ")")
        Rest(2000)
        print()
    } else {
        print("Mode: " . F_Modes[F_Mode])
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
            Rest(500)
            Send("F")
            print("Slots gained: " . Counter)
            Rest(500)
        }
    Rest(5000)
    print()
}

F10_Macro() {
    toggle := !toggle
    print("Healing")
    Rest(500)
    loop {
        if (!toggle) {
            Click("Up right")
            print()
            break
        }
        Click("Down right")
        Rest(20000)
        Click("Up right")
        Rest(14000)
    }
}

Magic_1_Macro() {
    openInventory(false, 10, 10)
    Colour := PixelGetColor(InvPixel.x, InvPixel.y)
    if (Colour = invColour) {
        transferFromInventory("spoiled")
        transferFromInventory("raw", ,true)
        Send("{Esc}")
    }
}

Magic_2_Macro() {
    openInventory(false, 10, 10)
    Colour := PixelGetColor(InvPixel.x, InvPixel.y)
    if (Colour = invColour) {
        transferFromInventory("berry", ,true)
        Send("{Esc}")
    }
}

Magic_3_Macro() {
    openInventory(false, 10, 10)
    Colour := PixelGetColor(InvPixel.x, InvPixel.y)
    if (Colour = invColour) {
        transferFromInventory()
        transferFromInventory(,, true)
        Send("{Esc}")
    }
}

Magic_4_Macro() {
    openInventory(false, 10, 10)
    Colour := PixelGetColor(InvPixel.x, InvPixel.y)
    if (Colour = invColour) {
        transferFromInventory("", 10)
    }
}

Magic_Macro() {
    funcName := "Magic_" . (F_Mode - 1) . "_Macro"
    run := Func(funcName)
    if (IsObject(run)) {
        Rest(100)
        %run%()
    } else if (F_Modes[F_Mode] != "Off") {
    	print("Unknown mode: " . F_Modes[F_Mode])
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
            ExitApp(1)
        }
    }
}

openInventory(localInventory := false, maxTries := 1000, precheckTries := 1) {
    res := WaitColour(InvPixel.x, InvPixel.y, invColour, precheckTries)
    if (res == true) {
        return true
    }
    Send(localInventory ? "i" : "f")
    return WaitColour(InvPixel.x, InvPixel.y, invColour, maxTries)
}

transferFromInventory(items := "", delay := 100, isLocalInventory := false) {
    if (items) {
        if (IsObject(items)) {
            for item in items {
                transferFromInventory(item, delay, isLocalInventory)
            }
            Return
        } else {
            MouseMove(isLocalInventory ? LocalSearch.x : RemoteSearch.x, isLocalInventory ? LocalSearch.y : RemoteSearch.y, 1)
            Rest(20)
            Click()
            Rest(50)
            Send(items)
        }
    }
    MouseMove(isLocalInventory ? LocalTransferAll.x : RemoteTransferAll.x, isLocalInventory ? LocalTransferAll.y : RemoteTransferAll.y, 1)
    Rest(50)
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
        Rest(100)
        Send(items)
        Rest(100)
    }
    MouseMove(RemoteDrop.x, RemoteDrop.y, 1)
    Click()
    Rest(delay)
}

WaitColour(x, y, colour, maxTries := 100, variation := 10) {
    loop maxTries {
        if (PixelSearch(a, b, x, y, x, y, colour, variation)) {
            return True
        } else {
            Rest(50)
        }
    }
    return False
}

ScaleCoords(x, y) {
    outx := (x / 1920) * A_ScreenWidth
    outy := (y / 1080) * A_ScreenHeight
    return {x: Floor(outx), y: Floor(outy)}
}

Rest(delay) {
    factor := 2
    Sleep(delay * factor)
}

print(msg := "", prefix := true) {
    out := (prefix = true) ? "[" . ProjectName . "] - " . msg : msg
    if (msg != "") {
        ToolTip(out, 0, 0)
    } else {
        ToolTip()
    }
}

DrawCircle(x, y, colour := "FF0066", transparency := 100) {
    MyGui := Gui.New()
    MyGui.Opt("-Caption +AlwaysOnTop +Owner")
    MyGui.BackColor := colour
    WinSetTransparent(transparency, MyGui.Hwnd)
    WinSetRegion("0-0 W40 H40 E", MyGui.Hwnd)
	x:=x-20
	y:=y-20
    MyGui.Show("w500 h500 X" . x . " Y" . y)
    return MyGui.Hwnd
}

RemoveCircle(Hwnd) {
    MyGui := GuiFromHwnd(Hwnd)
    MyGui.Destroy()
}