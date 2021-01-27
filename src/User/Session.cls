Class User.Session Extends (%Persistent, %XML.Adaptor) [ StorageStrategy = NewStorage1 ]
{

Index SessionIndex On (ContainerID, OpenTimestamp, UserIP, Username) [ IdKey, Unique ];

Property ContainerID As %String [ Required ];

Property OpenTimestamp As %String;

Property UserIP As %String;

Property Username As %String;

ClassMethod OutputTableData(
	pWhere As %String = "",
	pMaxRows = -1) As %Status
{
	Set tSC = $$$OK
	Set tQuery = "SELECT * FROM SQLUser.Session"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	//Write "Default Select Mode = ",tStatement.%SelectMode,!  // 0=Logical, 1=ODBC, 2=Display
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
 	While tResult.%Next() {
		Set tContainerID = tResult.ContainerID
		Set tOpenTimestamp = tResult.OpenTimestamp
		Set tUserIP = tResult.UserIP
		Set tUsername = tResult.Username
		Write !,"<tr><td>",tContainerID,"</td>"
		Write !,"<td>",tOpenTimestamp,"</td>"
		Write !,"<td>",tUserIP,"</td>"
		Write !,"<td>",tUsername,"</td></tr>"
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
