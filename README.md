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

## How to Work With it

If you want to deploy an SFTP server in a container, follow these steps:

```
$ git clone https://github.com/oliverwilms/sftp-server.git
$ cd sftp-server
$ docker-compose up -d --build
```

## What's insde the repo

# Dockerfile

The simplest dockerfile to start IRIS and load ObjectScript from /src/cls folder
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.

# .vscode/settings.json

Settings file to let you immedietly code in VSCode with [VSCode ObjectScript plugin](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript))

# .vscode/launch.json
Config file if you want to debug with VSCode ObjectScript
