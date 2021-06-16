$Compiler = ".\Compiler\Ahk2Exe.exe"
$BinFIle = ".\Compiler\Unicode 64-bit.bin"
$inFile = ".\ARK_All_In_One.ahk"
$outFile = ".\ARK_All_In_One.exe"
$iconFile = ".\icon.ico"

& $compiler  /bin $BinFIle /in $inFile /out $outFile /icon $iconFile /compress 2

$inFile = ".\updater.ahk"
$outFile = ".\updater.exe"

& $compiler  /bin $BinFIle /in $inFile /out $outFile /icon $iconFile /compress 2