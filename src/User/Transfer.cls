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
