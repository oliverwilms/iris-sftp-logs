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

I defined classes for Container, Session, and Transfer objects with mapping to globals. Class User.SFTPLog populates data into User.Container, User.Session, and User.Transfer classes.

## key-value globals

When I encounter a new ContainerID in log file, I store the timestamp when it was first encountered in LogContainer classmethod:

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

LogSessionOpen classmethod sets data into Session global:

Set ^Session(pContainerID,pTimestamp,tUserIP,tUsername) = pLogText

The Transfer global gets seeded in LogTransferOpen classmethod:

Set d = "^"
Set ^Transfer(pSessionID,pTimestamp) = tFilename_d_tFlags_d_tMode

Setting data value directly into global bypasses data validation such as MAXLEN defined in class definition.

## object

%Save performs validation

## SQL

Run query
