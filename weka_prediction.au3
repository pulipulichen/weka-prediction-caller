#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <AutoItConstants.au3>
#include <puli_utils.au3>
#pragma compile(Icon, 'weka-icon.ico')

; -----------------------------
; 取得資料

$extapp_weka = IniRead ( @ScriptDir & "\config.ini", "weka", "extapp_weka", "C:\Program Files\Weka-3-8\weka.jar" )
$extapp_weka = set_full_path($extapp_weka)

$test_set_arff = IniRead ( @ScriptDir & "\config.ini", "matlab", "test_set_arff", ".\iris-test-set.arff" )
If $CmdLine[0] > 0 Then
   ; 測試集可以從參數輸入
   $test_set_arff = $CmdLine[1]
EndIf
$test_set_arff = set_full_path($test_set_arff)

$weka_classifier = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_classifier", "weka.classifiers.functions.SMO" )
$weka_model = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_model", ".\iris-smo.model" )
$weka_model = set_full_path($weka_model)


$weka_run_title = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_run_title", "Weka" )
$weka_run_message = IniRead ( @ScriptDir & "\config.ini", "weka", "weka_run_message", "Please wait. Predicting..." )
SplashTextOn($weka_run_title, $weka_run_message, 300, 40) ; https://www.autoitscript.com/autoit3/docs/functions/SplashTextOn.htm

; -----------------------------
; 開始進行預測

$cmd_weka = @comspec & ' /C Java -cp ' & $extapp_weka & ' weka.Run ' & $weka_classifier & ' -T ' & $test_set_arff & ' -l ' & $weka_model & ' -p 0'
$DOS = Run($cmd_weka,  @SystemDir, Default, $STDOUT_CHILD)
ProcessWaitClose($DOS)
Local $predict_result = StdoutRead($DOS)
$predict_result = trim($predict_result)

; ----------------------------------

; 分析預測結果
Local $aArray = StringSplit($predict_result, @CRLF)
$predict_result = $aArray[($aArray[0])]
$predict_result = trim($predict_result)
$aArray = StringSplit($predict_result, ':')
$predict_result = $aArray[($aArray[0])]
$predict_result = trim($predict_result)
$aArray = StringSplit($predict_result, ' ')

Local $predict_class = $aArray[1]
$predict_class = trim($predict_class)

Local $predict_prob = $aArray[($aArray[0])]
$predict_prob = trim($predict_prob)
$predict_prob = Number($predict_prob)
$predict_prob = $predict_prob * 100

;MsgBox(0, "weka_predict.au3", $predict_class & @CRLF & $predict_prop)

; -------------------------
; 進行預測之後的動作
Local $after_predict_cmd = IniRead ( @ScriptDir & "\config.ini", "weka", "after_predict_cmd", "C:\Program Files\Internet Explorer\iexplore.exe -k https://docs.google.com/forms/d/e/1FAIpQLSeWynGUR3vzZc6E7pVMEYpruAnl66vA9aS4bVOw5Tp6rC1FCw/viewform?usp=pp_url&entry.1291062876={predictclass}&entry.422415105={prob}" )

$after_predict_cmd = StringReplace($after_predict_cmd, "{predictclass}", $predict_class)
$after_predict_cmd = StringReplace($after_predict_cmd, "{prob}", $predict_prob)

;MsgBox(0, "weka_predict.au3", $after_predict_cmd)
Run($after_predict_cmd)
