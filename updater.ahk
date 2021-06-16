; Auto Update for AHK v2
; Copyright LKD70 (Luke) 2021
; License: AGPL-3.0

; usage: updater.exe <File Name> <Download URL>
; File name is the name of the ahk exe you wish to update without the .exe extension

if (A_Args.Length = 2) {
    file_name := A_Args[1]
    URL := A_Args[2]
    
    temp_file := file_name . ".TMP"
    if (!FileExist(temp_file)) {
        ToolTip("Downloading update to " . file_name, 0, 0)
        Download(URL, file_name . ".TMP")
    }
    update(file_name . ".exe", temp_file)
    Run(file_name . ".exe /updated")

} else {
    MsgBox("Updater cannot be ran like this.")
    ExitApp(1) ; Exit as we were not passed an argument for the file name
}

update(file, temp) {
    ToolTip("Updating program", 0, 0)
    CloseApp(file) ; Close the app so we can remove it
    FileDelete(file)
    FileMove(A_WorkingDir . "\" . temp, A_WorkingDir . "\" . file)
    ToolTip("", 0, 0)
}

CloseApp(window) {
    if (WinExist("ahk_exe " . window)) {
        WinKill("ahk_exe " . window)
    }
}