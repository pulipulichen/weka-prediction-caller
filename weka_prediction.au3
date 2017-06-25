#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <AutoItConstants.au3>
#include <puli_utils.au3>
#pragma compile(Icon, 'lib\icon\weka-icon.ico')
#AutoIt3Wrapper_UseAnsi=n

$extapp_weka = IniRead ( @ScriptDir & "\config.ini", "weka", "extapp_weka", "C:\Program Files\Weka-3-8\weka.jar" )
$extapp_weka = set_full_path($extapp_weka)
$weka_classifier = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_classifier", "weka.classifiers.functions.SMO" )
$weka_model = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_model", ".\lib\weka\smo.model" )
$weka_model = set_full_path($weka_model)
$test_set_arff = IniRead ( @ScriptDir & "\config.ini", "matlab", "brainwave_arff", ".\data\brainwave_test_set.arff" )
If $CmdLine[0] > 0 Then
   $test_set_arff = $CmdLine[1]
EndIf
$test_set_arff = set_full_path($test_set_arff)
;$predict_result = IniRead ( @ScriptDir & "\config.ini", "config", "weka_predict_result", "data\predict_result.txt" )

$weka_run_title = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_run_title", "Weka" )
$weka_run_message = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_run_message", "Analyzing. Please wait..." )
;MsgBox(0, "weka_predict.au3", $weka_run_message)
SplashTextOn($weka_run_title, $weka_run_message, 300, 40) ; https://www.autoitscript.com/autoit3/docs/functions/SplashTextOn.htm

;$cmd_weka = @comspec & ' /C Java -cp "' & @ScriptDir & "\" & $extapp_weka & '" ' & $weka_classifier & ' -T "' & @ScriptDir & "\" & $brainwave_arff & '" -l "' & @ScriptDir & "\" & $weka_model & '" -p 0'
$cmd_weka = @comspec & ' /C Java -cp ' & $extapp_weka & ' weka.Run ' & $weka_classifier & ' -T ' & $test_set_arff & ' -l ' & $weka_model & ' -p 0'

;MsgBox(0, "weka_predict.au3", $cmd_weka)
;exit


$DOS = Run($cmd_weka,  @SystemDir, Default, $STDOUT_CHILD)
ProcessWaitClose($DOS)
Local $predict_result = StdoutRead($DOS)
$predict_result = StringStripWS($predict_result, $STR_STRIPLEADING + $STR_STRIPTRAILING)

Local $aArray = StringSplit($predict_result, @CRLF)
$predict_result = $aArray[($aArray[0])]
$predict_result = StringStripWS($predict_result, $STR_STRIPLEADING + $STR_STRIPTRAILING)
; 1        1:? 3:Iris-virginica       0.667

$aArray = StringSplit($predict_result, ':')
$predict_result = $aArray[($aArray[0])]
$predict_result = StringStripWS($predict_result, $STR_STRIPLEADING + $STR_STRIPTRAILING)
; Iris-virginica       0.667

;MsgBox(0, "weka_predict.au3", $predict_result)
; ------------------------------------

$aArray = StringSplit($predict_result, ' ')
Local $predict_class = $aArray[1]
$predict_class = StringStripWS($predict_class, $STR_STRIPLEADING + $STR_STRIPTRAILING)

Local $predict_prop = $aArray[($aArray[0])]
$predict_prop = StringStripWS($predict_prop, $STR_STRIPLEADING + $STR_STRIPTRAILING)
$predict_prop = Number($predict_prop)
$predict_prop = $predict_prop * 100

;MsgBox(0, "weka_predict.au3", $predict_class & @CRLF & $predict_prop)

; -------------------------
; 開啟網址
Local $after_predict_cmd = IniRead ( @ScriptDir & "\config.ini", "media", "after_predict_cmd", "C:\Program Files\Internet Explorer\iexplore.exe -k https://docs.google.com/forms/d/e/1FAIpQLSfKkm5WUkKViB8XRnwNPIMyAszVyZeQq2So-B7TpnQ6U6qCwQ/viewform?usp=pp_url&entry.610432172={predictclass}&entry.42546734={prop}" )
$after_predict_cmd = StringReplace($after_predict_cmd, "{predictclass}", $predict_class)
$after_predict_cmd = StringReplace($after_predict_cmd, "{prop}", $predict_prop)

;MsgBox(0, "weka_predict.au3", $after_predict_cmd)
Run($after_predict_cmd)
