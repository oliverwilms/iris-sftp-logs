Class User.SFTPLog
{

ClassMethod DebugStatus(pStatus As %Status) As %Status
{
	Set tStatus = $System.Status.GetOneErrorText(pStatus)
	Quit ..DebugTEST(tStatus)
}

ClassMethod DebugTEST(strMessage As %String = "") As %Status
{
	Set ^TEST($I(^TEST)) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage
	Quit $$$OK
}

ClassMethod Test() As %Status
{
	Set tDirectory = "/sftp/log/"
	Set tFilename = "sftp.log"
	Set tSC = ..ReadLog(tDirectory,tFilename)
	Quit tSC
}

ClassMethod LogContainer(
	pContainerID As %String = "",
	pTimestamp As %String = "") As %Status
{
	Set tSC = $$$OK
	If (pContainerID = "") Quit tSC
	If $Data(^Container(pContainerID)) Quit tSC
	Set ^Container(pContainerID) = pTimestamp
	Quit tSC
}

ClassMethod LogSessionOpen(
	pContainerID As %String = "",
	pTimestamp As %String = "",
	pLogText As %String = "") As %String
{
	Set tSC = $$$OK
	If (pContainerID = "") Set pContainerID = 0
	If (pTimestamp = "") Set pTimestamp = 0
	Set tFind = "session opened for local user "
	Set tData = $Extract(pLogText,$Length(tFind)+1,*)
	Set tUsername = $Piece(tData," ",1)
	If (tUsername = "") Set tUsername = 0
	Set tFind = $Piece(tData," ",2)  // from
	Set tUserIP = $Piece(tData," ",3)
	If (tUserIP = "") Set tUserIP = 0
	Set d = "||"
	Set tSessionID = pContainerID_d_pTimestamp_d_tUserIP_d_tUsername
	If $Data(^Session(pContainerID,pTimestamp,tUserIP,tUsername)) Quit tSessionID
	Set ^Session(pContainerID,pTimestamp,tUserIP,tUsername) = pLogText
	Quit tSessionID
}

ClassMethod LogTransferOpen(
	pSessionID As %String = "",
	pTimestamp As %String = "",
	pLogText As %String = "") As %Status
{
	Set tSC = $$$OK
	If (pSessionID = "") Set pSessionID = 0
	If (pTimestamp = "") Set pTimestamp = 0
	Set d = "||"
	Set tTransferID = pSessionID_d_pTimestamp
	If $Data(^Transfer(pSessionID,pTimestamp)) Quit tTransferID
	Set tFind = "open "
	Set tData = $Extract(pLogText,$Length(tFind)+1,*)
	Set tFind = " flags "
	Set tFilename = $Piece(tData,tFind,1)
	Set tData = $Piece(tData,tFind,2)
	Set tFind = " mode "
	Set tFlags = $Piece(tData,tFind,1)
	Set tMode = $Piece(tData,tFind,2)
	// *** Setting global directly bypasses validation ***
	Set d = "^"
	Set ^Transfer(pSessionID,pTimestamp) = tFilename_d_tFlags_d_tMode
	Quit tTransferID
}

ClassMethod LogTransferClose(
	pTransferID As %String = "",
	pTimestamp As %String = "",
	pLogText As %String = "") As %Status
{
	Set tSC = $$$OK
	If (pTransferID = "") Set pTransferID = 0
	If (pTimestamp = "") Set pTimestamp = 0
	Set tFind = "close "
	Set tData = $Extract(pLogText,$Length(tFind)+1,*)
	Set tFind = " bytes read "
	Set tFilename = $Piece(tData,tFind,1)
	Set tData = $Piece(tData,tFind,2)
	Set tFind = " written "
	Set tBytesRead = $Piece(tData,tFind,1)
	Set tBytesWritten = $Piece(tData,tFind,2)
	Set objTransfer = ##class(Transfer).%OpenId(pTransferID,,.tSC)
	If $$$ISERR(tSC) {
		Do ..DebugStatus(tSC)
		Quit tSC
	}
	Set objTransfer.BytesRead = tBytesRead
	Set objTransfer.BytesWritten = tBytesWritten
	Set objTransfer.CloseTimestamp = pTimestamp
	Set tSC = objTransfer.%Save()
	If $$$ISERR(tSC) {
		Do ..DebugStatus(tSC)
		Quit tSC
	}
	Quit tSC
}

ClassMethod OneLine(
	pLine As %String = "",
	ByRef pSessionID As %String,
	ByRef pTransferID As %String) As %Status
{
	Set tSC = $$$OK
	Set tTimestamp = $Piece(pLine," ",1)
	Set tContainerID = $Piece(pLine," ",2)
	Set tSC = ..LogContainer(tContainerID,tTimestamp)
	Set tCommand = $Piece(pLine," ",3)
	Set tLogText = $Piece(pLine," ",4,*)
	If (tLogText [ "session opened") {
		Set pSessionID = ..LogSessionOpen(tContainerID,tTimestamp,tLogText)
		Quit tSC
	}
	If ($Extract(tLogText,1,4) [ "open") {
		Set pTransferID = ..LogTransferOpen(pSessionID,tTimestamp,tLogText)
		Quit tSC
	}
	If ($Extract(tLogText,1,5) [ "close") {
		Set tSC = ..LogTransferClose(pTransferID,tTimestamp,tLogText)
		Quit $$$OK
	}
	Quit $$$OK
}

ClassMethod ReadLog(
	pDirectory As %String = "",
	pFilename As %String = "") As %Status
{
	Set tSC = $$$OK
	Set tFile = pDirectory_pFilename
	Set tSC = ##class(%File).DirectoryExists(pDirectory)
	If '$$$ISOK(tSC) Quit tSC
	Set tSC = ##class(%File).Exists(tFile)
	If '$$$ISOK(tSC) Quit tSC
	Set tF = ##class(%File).%New(tFile)
	If '$IsObject(tF) Quit tSC
	Set tSC = tF.Open("R")
	If '$$$ISOK(tSC) Quit tSC
	For {
		Set tLen = 32000
		Set tLog = tF.Read(.tLen,.tSC)
		If '$$$ISOK(tSC) Quit
		If (tLen < 2) Quit
		Set tSC = ..OneLine(tLog,.tSessionID,.tTransferID)
	}
	Do tF.Close()
	Set tF = ""
	Quit tSC
}

}
