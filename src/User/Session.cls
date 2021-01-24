Class User.Session Extends (%Persistent, %XML.Adaptor) [ StorageStrategy = NewStorage1 ]
{

Index SessionIndex On (ContainerID, OpenTimestamp, UserIP, Username) [ IdKey, Unique ];

Property ContainerID As %String [ Required ];

Property OpenTimestamp As %String;

Property UserIP As %String;

Property Username As %String;

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
