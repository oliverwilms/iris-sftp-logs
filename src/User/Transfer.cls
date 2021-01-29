Class User.Transfer Extends (%Persistent, %XML.Adaptor) [ StorageStrategy = NewStorage1 ]
{

Index TransferIndex On (Session, OpenTimestamp) [ IdKey ];

Property Session As Session [ Required ];

Property OpenTimestamp As %String;

Property Filename As %String(MAXLEN = 9999);

Property Flags As %String;

Property Mode As %String;

Property BytesRead As %Integer;

Property BytesWritten As %Integer;

Property CloseTimestamp As %String;

ClassMethod OutputTableData(
	pWhere As %String = "",
	pTrClick As %String = "alert('transfer=#');",
	pMaxRows = -1) As %Status
{
	Do ##class(SFTPLog).DebugTEST("User.Transfer - OutputTableData")
	Do ##class(SFTPLog).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE Session = '"_pWhere_"'"  // This did not return any result
	If (pWhere '= "") Set tWHERE = " WHERE Session LIKE '"_$TRANSLATE(pWhere," ","%")_"'"
	//Set tWHERE = ..createWHERE(pWhere)
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
		Write !,"<td>",tResult.Session,"</td>"
		Write !,"<td>",tResult.OpenTimestamp,"</td>"
		Write !,"<td>",tResult.Filename,"</td>"
		Write !,"<td>",tResult.CloseTimestamp,"</td></tr>"
	}
	Quit tSC
}

Storage NewStorage1
{
<Data name="Node1"/>
<SQLMap name="Map1">
<Data name="BytesRead">
<Delimiter>"^"</Delimiter>
<Piece>4</Piece>
</Data>
<Data name="BytesWritten">
<Delimiter>"^"</Delimiter>
<Piece>5</Piece>
</Data>
<Data name="CloseTimestamp">
<Delimiter>"^"</Delimiter>
<Piece>6</Piece>
</Data>
<Data name="Filename">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="Flags">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="Mode">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Global>^Transfer</Global>
<Subscript name="1">
<Expression>{Session}</Expression>
</Subscript>
<Subscript name="2">
<Expression>{OpenTimestamp}</Expression>
</Subscript>
<Type>data</Type>
</SQLMap>
<StreamLocation>^User.TransferS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
