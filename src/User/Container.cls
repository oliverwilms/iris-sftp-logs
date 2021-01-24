Class User.Container Extends (%Persistent, %XML.Adaptor) [ StorageStrategy = NewStorage1 ]
{

Property ContainerID As %String [ Required ];

Index ContainerIDIndex On ContainerID [ IdKey, Unique ];

Property FirstTimestamp As %String;

Storage NewStorage1
{
<Data name="Node1"/>
<SQLMap name="Map1">
<ConditionalWithHostVars></ConditionalWithHostVars>
<Data name="FirstTimestamp">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Global>^Container</Global>
<Subscript name="1">
<Expression>{ContainerID}</Expression>
</Subscript>
<Type>data</Type>
</SQLMap>
<StreamLocation>^User.ContainerS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
