Class User.Session Extends (%Persistent, %XML.Adaptor) [ StorageStrategy = NewStorage1 ]
{

Index SessionIndex On (ContainerID, OpenTimestamp, UserIP, Username) [ IdKey, Unique ];

Property ContainerID As %String [ Required ];

Property OpenTimestamp As %String;

Property UserIP As %String;

Property Username As %String;

ClassMethod createWHERE(pWhere As %String = "") As %String
{
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE ID = '"_pWhere_"'"  // This did not return any result
	If (pWhere '= "") Set tWHERE = " WHERE ID LIKE '"_pWhere_"%'"  // This did not return any result
	Set d = "||"
	Set tContainerID = $Piece(pWhere,d,1)
	Set tTimestamp = $Piece(pWhere,d,2)
	Set tUserIP = $Piece(pWhere,d,3)
	Set tUsername = $Piece(pWhere,d,4)
	Set tWHERE = " WHERE ContainerID LIKE '"_tContainerID_"%'"
	//Set tWHERE = tWHERE_" AND OpenTimestamp LIKE '"_tTimestamp_"%'"  // This did not return any result
	// 2021-01-23T21:27:03.685500 00:00  // ID substitutes space for plus sign
	Set tWHERE = tWHERE_" AND OpenTimestamp LIKE '"_$Piece(tTimestamp," ",1)_"%'"
	Set tWHERE = tWHERE_" AND UserIP LIKE '"_tUserIP_"%'"
	Set tWHERE = tWHERE_" AND Username LIKE '"_tUsername_"%'"
	Quit tWHERE
}

ClassMethod OutputTableData(
	pWhere As %String = "",
	pTrClick As %String = "alert('session=#');",
	pMaxRows = -1) As %Status
{
	Do ##class(SFTPLog).DebugTEST("User.Session - OutputTableData")
	Do ##class(SFTPLog).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE ID = '"_pWhere_"'"
	Set tWHERE = ..createWHERE(pWhere)
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

Storage NewStorage1
{
<Data name="Node1"/>
<SQLMap name="Map1">
<Global>^Session</Global>
<Subscript name="1">
<Expression>{ContainerID}</Expression>
</Subscript>
<Subscript name="2">
<Expression>{OpenTimestamp}</Expression>
</Subscript>
<Subscript name="3">
<Expression>{UserIP}</Expression>
</Subscript>
<Subscript name="4">
<Expression>{Username}</Expression>
</Subscript>
<Type>data</Type>
</SQLMap>
<StreamLocation>^User.SessionS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
