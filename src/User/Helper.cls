Class User.Helper
{

ClassMethod CallRESTapi(
	pIris As %String = 0,
	pUrl As %String,
	ByRef pResponseData As %DynamicObject,
	pType As %String = "GET") As %Status
{
	#define maxRESTapiErr 3
	#define maxRetries 2
	#define timeout 3
	Set tErrorCount = 0
	Set tParamIRIS = pIris
	If (pIris = 0) Set pIris = "127.0.0.1:52773"
	Set tServer = $Piece(pIris,":",1)
	Set tPort = $Piece(pIris,":",2)
	Do {
		Set tRetryFlag = 0
		Set pResponse = $$$NULLOREF
		Set tRequest = ##class(%Net.HttpRequest).%New()

		// InitiateAuthentication does not exist in HealthShare versions
		Try {
			//Supported schemes are Negotiate, NTLM and Basic.
			Set tRequest.InitiateAuthentication = "Basic"
			Set tRequest.Username = "_SYSTEM"
			Set tRequest.Password = "SYS"
		} Catch {
		}

		//Set tRequest.Server = ""  // This defaults to 'localhost', i.e. your current machine if not specified.
		Set tRequest.Port = tPort
		If (tServer '= "") Set tRequest.Server = tServer
		Set tRequest.Timeout = $$$timeout
		Set type = pType
		Set location = $Get(pUrl)
		Set location = ##class(%CSP.Page).EscapeURL(location)
		Set test = 0
		Set reset = 1
		Set tSC = tRequest.Send(type,location,test,reset)
		If $$$ISERR(tSC) Do ..DebugStatus(tSC)
		Set pResponse = tRequest.HttpResponse
		If $IsObject(pResponse) {
			If (pResponse.StatusCode '= 200) {
				Do ..DebugTEST("StatusCode = "_pResponse.StatusCode)
				Do ..DebugTEST("ReasonPhrase = "_pResponse.ReasonPhrase)
			}
			If (pResponse.StatusCode = 500) {  // Internal Server Error
				If $Increment(tErrorCount) <= $$$maxRetries Set tRetryFlag = 1
			}
		} Else {
			Do ..DebugTEST("HttpResponse = "_pResponse)
		}
	} While tRetryFlag

	If $IsObject(pResponse) {
		#dim tDataStream As %Stream.GlobalBinary
		Set tDataStream = pResponse.Data
		Set tDataString = tDataStream.Read(.len,.sc)
		If $$$ISOK(sc) {
			Do ..DebugTEST("tDataString = "_tDataString)
		} Else {
			Do ..DebugTEST("Data = "_pResponse.Data)
			Do ..DebugTEST("len = "_$Get(len))
			Do ..DebugStatus(sc)
		}
		Try {
			Set pResponseData = ##class(%DynamicObject).%FromJSON(tDataString)
		}
		Catch {
			Set tSC = $$$ERROR($$$GeneralError,"JSON error")
			If (pResponse.StatusCode '= 200) {
				Set tSC = $$$ERROR($$$GeneralError,"Response was "_pResponse.StatusCode_" / "_pResponse.ReasonPhrase)
			}
			Do ..DebugStatus(tSC)
		}
	}
	If $$$ISOK(tSC) {
		Quit tSC
	}
	Set pIris = $Get(tParamIRIS,pIris)
	Set myUnitTest = $Get(^myUnitTests)
	If (myUnitTest = "") Quit $$$ERROR($$$GeneralError,"^myUnitTests undefined")
	If myUnitTest {
		Set tRESTapiErr = $Get(^myUnitTests(myUnitTest,pIris,"RESTapiErr"),0)
		Set ^myUnitTests(myUnitTest,pIris,"RESTapiErr") = $Increment(tRESTapiErr)
	}
	Quit tSC
}

/// 2021-01-23T21:27:03.685500+00:00
ClassMethod ConvertTimestampToTime(pOpenTimestamp As %String = "") As %String
{
	Set tReturn = ""
	If pOpenTimestamp?4N1"-"2N1"-"2N1"T"2N1":"2N1":"2N.E {
		Set tTime = $Extract(pOpenTimestamp,12,*)  // 21:27:03.685500+00:00
		Set tReturn = $Piece(tTime,"+",1)  // 21:27:03.685500
	}
	Quit tReturn
}

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

ClassMethod SessionTableData(
	pWhere As %String = "",
	pTrClick As %String = "alert('session=#');",
	pMaxRows = -1) As %Status
{
	Do ##class(SFTPLog).DebugTEST("User.Helper - SessionTableData")
	Do ##class(SFTPLog).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ##class(Session).createWHERE(pWhere)
	Set tQuery = "SELECT * FROM SQLUser.Session"_tWHERE
	Do ##class(SFTPLog).DebugTEST("tQuery = "_tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
 	While tResult.%Next() {
		Write !,"<tr onclick=",tQuote,$Replace(pTrClick,"#",tResult.ID),tQuote,">"
		Write !,"<td>",tResult.ContainerID,"</td>"
		Write !,"<td>",tResult.OpenTimestamp,"</td>"
		Write !,"<td>",tResult.UserIP,"</td>"
		Write !,"<td>",tResult.Username,"</td></tr>"
	}
	Quit tSC
}

ClassMethod TransferTableData(
	pWhere As %String = "",
	pTrClick As %String = "alert('transfer=#');",
	pMaxRows = -1) As %Status
{
	Do ##class(SFTPLog).DebugTEST("User.Helper - TransferTableData")
	Do ##class(SFTPLog).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE Session = '"_pWhere_"'"  // This did not return any result
	If (pWhere '= "") Set tWHERE = " WHERE Session LIKE '"_$TRANSLATE(pWhere," ","%")_"'"
	Set tQuery = "SELECT * FROM SQLUser.Transfer"_tWHERE
	Do ##class(SFTPLog).DebugTEST("tQuery = "_tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
 	While tResult.%Next() {
		Write !,"<tr onclick=",tQuote,$Replace(pTrClick,"#",tResult.ID),tQuote,">"
		Set pIris = 0
		Set pType = "GET"
		Set pUrl = "/restapi/transfer/tr/"_tResult.ID
		Set tSC = ..CallRESTapi(pIris,pUrl,.pResponseData,pType)

		//Write !,"<td>",tResult.Session,"</td>"
		Write !,"<td>",pResponseData.OpenTimestamp,"</td>"
		Write !,"<td>",tResult.Filename,"</td>"
		Write !,"<td>",tResult.Flags,"</td>"
		Write !,"<td>",tResult.Mode,"</td>"
		Write !,"<td>",tResult.BytesRead,"</td>"
		Write !,"<td>",tResult.BytesWritten,"</td>"
		Write !,"<td>",tResult.CloseTimestamp,"</td></tr>"
	}
	Quit tSC
}

}
