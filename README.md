## iris-sftp-logs
This was started from template of a Multi-model REST API application built with ObjectScript in InterSystems IRIS.
It also has OPEN API spec, 
can be developed with Docker and VSCode,
can be deployed as ZPM module.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation with ZPM

zpm:USER>install iris-sftp-logs

## Installation for development

Clone/git pull the repo into any local directory like it is shown below:

```
$ git clone https://github.com/oliverwilms/iris-sftp-logs.git
```

Open the terminal in this directory:
```
$ cd iris-sftp-logs
```
Run:
```
$ docker-compose up -d --build
```

## Deploy SFTP server

If you want to deploy an SFTP server in a container, follow these steps:

```
$ git clone https://github.com/oliverwilms/sftp-server.git
$ cd sftp-server
$ docker-compose up -d --build
```

# How iris-sftp-logs uses IRIS multi-model data platform

I defined classes for Container, Session, and Transfer objects with mapping to globals. Class User.SFTPLog populates data into User.Container, User.Session, and User.Transfer classes. It can be invoked from terminal or sftplog.csp (see below).

## key-value globals

When I encounter a new ContainerID in log file, I store the timestamp when it was first encountered in LogContainer classmethod:

```
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
```

LogSessionOpen classmethod sets data into Session global:

```
Set ^Session(pContainerID,pTimestamp,tUserIP,tUsername) = pLogText
```

The Transfer global gets seeded in LogTransferOpen classmethod:

```
Set d = "^"
Set ^Transfer(pSessionID,pTimestamp) = tFilename_d_tFlags_d_tMode
```

Setting data value directly into global bypasses data validation such as MAXLEN defined in class definition.

## object

When I update a Transfer with Bytes Read, Bytes Written, and Close Timestamp in LogTransferClose classmethod, I instantiate an object and use %Save method which performs validation:

```
Set objTransfer = ##class(Transfer).%OpenId(pTransferID,,.tSC)
If $$$ISERR(tSC) {
	Do ..DebugStatus(tSC)
	Quit tSC
}
Set objTransfer.BytesRead = tBytesRead
Set objTransfer.BytesWritten = tBytesWritten
Set objTransfer.CloseTimestamp = pTimestamp
Set tSC = objTransfer.%Save()
```

## SQL

I created OutputTableData classmethod for Session class which gets called from sftplog.csp to display a table with Session data.

```
ClassMethod OutputTableData(
	pWhere As %String = "",
	pMaxRows = -1) As %Status
{
	Set tSC = $$$OK
	Set tQuery = "SELECT * FROM SQLUser.Session"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
 	While tResult.%Next() {
		Write !,"<tr><td>",tResult.ContainerID,"</td>"
		Write !,"<td>",tResult.OpenTimestamp,"</td>"
		Write !,"<td>",tResult.UserIP,"</td>"
		Write !,"<td>",tResult.Username,"</td></tr>"
	}
	Quit tSC
}
```

iris-sftp-logs includes a [csp](https://github.com/oliverwilms/iris-sftp-logs/blob/master/csp/sftplog.csp) page to manage your sftp log files. You can access it at http://localhost:52773/sftplog/sftplog.csp. You need to replace localhost with the ip address if iris-sftp-logs runs on a remote server. Change the port number if you use a different port.
<img width="1411" alt="Screenshot" src="https://raw.githubusercontent.com/oliverwilms/bilder/main/sftplog.PNG">

The repository includes a [sample sftp log file](https://github.com/oliverwilms/iris-sftp-logs/blob/master/sftp.log). You can import it into IRIS database. Enter the directory (/irisrun/repo/) and filename (sftp.log), check the Import checkbox, and click Submit.
<img width="1411" alt="Screenshot" src="https://raw.githubusercontent.com/oliverwilms/bilder/main/sftplog_import.PNG">

You will see contents of the log file displayed on the bottom of the screen.
<img width="1411" alt="Screenshot" src="https://raw.githubusercontent.com/oliverwilms/bilder/main/sftplog_import_after.PNG">
