' SetLogonAsAServiceRight.vbs
' Grant Logon As A Service Right.
' ------------------------------------------------------' 

Dim strUserName,ConfigFileName,OrgStr,RepStr,inputFile,strInputFile,outputFile,obj 
strUserName = "Administrator"
Dim oShell 
Set oShell = CreateObject ("WScript.Shell")
oShell.Run "secedit /export /cfg config.inf", 0, true 
oShell.Run "secedit /import /cfg config.inf /db database.sdb", 0, true

ConfigFileName = "config.inf"
OrgStr = "SeServiceLogonRight ="
RepStr = "SeServiceLogonRight = " & strUserName & ","
Set inputFile = CreateObject("Scripting.FileSystemObject").OpenTextFile("config.inf", 1,1,-1)
strInputFile = inputFile.ReadAll
inputFile.Close
Set inputFile = Nothing

Set outputFile =   CreateObject("Scripting.FileSystemObject").OpenTextFile("config.inf",2,1,-1)
outputFile.Write (Replace(strInputFile,OrgStr,RepStr))
outputFile.Close
Set outputFile = Nothing

oShell.Run "secedit /configure /db database.sdb /cfg config.inf",0,true
set oShell= Nothing

Set obj = CreateObject("Scripting.FileSystemObject")
obj.DeleteFile("config.inf") 
obj.DeleteFile("database.sdb")
