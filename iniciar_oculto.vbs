Set WshShell = CreateObject("WScript.Shell")
WshShell.Run Chr(34) & Replace(WScript.ScriptFullName, "iniciar_oculto.vbs", "iniciar_languagetool.bat") & Chr(34), 0, False
Set WshShell = Nothing
