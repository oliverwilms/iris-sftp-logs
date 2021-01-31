Class User.REST Extends %CSP.REST
{

Parameter UseSession As Integer = 1;

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/:sftplog" Method="POST" Call="PostOneLine" />
<Route Url="/:sftplog/:pSessionID" Method="POST" Call="PostOneLine" />
<Route Url="/:sftplog/:pSessionID/:pTransferID" Method="POST" Call="PostOneLine" />
<Route Url="/transfer/tr/:pTransferID" Method="GET" Call="TransferTrData" />
</Routes>
}

ClassMethod PostOneLine(
	pLine As %String = "",
	pSessionID As %String,
	pTransferID As %String) As %Status
{
	Do ##class(SFTPLog).DebugTEST("pLine = "_pLine)
	Do ##class(SFTPLog).DebugTEST("pSessionID = "_$Get(pSessionID))
	Do ##class(SFTPLog).DebugTEST("pTransferID = "_$Get(pTransferID))

	#dim tSC  As %Status = ##class(SFTPLog).OneLine(pLine,.pSessionID,.pTransferID)
	Do ##class(SFTPLog).DebugTEST("pSessionID = "_$Get(pSessionID))
	Do ##class(SFTPLog).DebugTEST("pTransferID = "_$Get(pTransferID))
	Set data = {}
	Set data.SessionID = $Get(pSessionID)
	Set data.TransferID = $Get(pTransferID)
	Write data.%ToJSON()
	Quit tSC
}

ClassMethod TransferTrData(pTransferID As %String) As %Status
{
	Do ##class(SFTPLog).DebugTEST("pTransferID = "_$Get(pTransferID))
	#dim tSC As %Status = $$$OK
	Set objTransfer = ##class(Transfer).%OpenId(pTransferID,,.tSC)
	Do ##class(Helper).DebugStatus(tSC)
	If $IsObject(objTransfer) {
		Set tOpenTimestamp = objTransfer.OpenTimestamp
		Set tCloseTimestamp = objTransfer.CloseTimestamp
	}
	Set data = {}
	Set data.OpenTimestamp = ##class(Helper).ConvertTimestampToTime(tOpenTimestamp)
	Set data.CloseTimestamp = ##class(Helper).ConvertTimestampToTime(tCloseTimestamp)
	Set data.TransferID = $Get(pTransferID)
	Write data.%ToJSON()
	Quit tSC
}

}
