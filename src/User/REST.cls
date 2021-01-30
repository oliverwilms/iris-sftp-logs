Class User.REST Extends %CSP.REST
{

Parameter UseSession As Integer = 1;

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/:sftplog" Method="POST" Call="PostOneLine" />
</Routes>
}

ClassMethod PostOneLine(
	pLine As %String = "",
	pSessionID As %String,
	pTransferID As %String) As %Status
{
	#dim tSC  As %Status = ##class(SFTPLog).OneLine(pLine,.pSessionID,.pTransferID)
	Quit tSC
}

}
