Class App.Installer
{

XData setup
{
<Manifest>
  <Default Name="SourceDir" Value="/opt/sftplog/src"/>
  <Default Name="Namespace" Value="SFTPLOG"/>

  <Namespace Name="${Namespace}" Code="${Namespace}" Data="${Namespace}" Create="yes" Ensemble="1">
    <Configuration>
      <Database Name="${Namespace}" Dir="/voldata/irisdb/sftplog" Create="yes" Resource="%DB_${Namespace}"/>
    </Configuration>
    <Import File="${SourceDir}" Flags="ck" Recurse="1"/>
  </Namespace>
  
  <If Condition='(##class(Security.Applications).Exists("/sftplog")=0)'>
      <Log Text="Creating web application /sftplog" Level="0"/>
      <RunInstall Class="App.Installer" Method="CreateWebAppSFTPLog"/>
    </If>
    <If Condition='(##class(Security.Applications).Exists("/restapi")=0)'>
      <Log Text="Creating web application /restapi" Level="0"/>
      <RunInstall Class="App.Installer" Method="CreateWebAppREST"/>
    </If>
</Manifest>
}

ClassMethod CreateWebAppSFTPLog(pVars,pLogLevel,tInstaller) As %Status
{
	If $IsObject($Get(tInstaller)) {
  Set Namespace = tInstaller.Evaluate("${Namespace}")
  Do tInstaller.PushNS("%SYS")
	}
  Do ##class(Security.System).GetInstallationSecuritySetting(.security)
  If (security="None") {
    Set cspProperties("AutheEnabled") = $$$AutheUnauthenticated
  } Else {
    Set cspProperties("AutheEnabled") = $$$AutheCache // Password
  }
  Set cspName = "/sftplog"
  Set cspProperties("NameSpace") = $Get(Namespace,"SFTPLOG")
  Set cspProperties("Enabled") = 1
  Set cspProperties("AutheEnabled") = $$$AutheUnauthenticated + $$$AutheCache
  Set cspProperties("DeepSeeEnabled") = 1
  Set cspProperties("iKnowEnabled") = 0
  Set cspProperties("Path") = "/voldata/icsp/sftplog"
  Set cspProperties("Resource") = ""
  Set cspProperties("ServeFiles") = 1
  Set tSC = ##class(Security.Applications).Create(cspName,.cspProperties)
  Do tInstaller.PopNS()
  If $$$ISERR(tSC) Throw ##class(%Installer.Exception).CreateFromStatus(tSC)
  Quit $$$OK
}

ClassMethod CreateWebAppREST(pVars,pLogLevel,tInstaller) As %Status
{
  Set Namespace = tInstaller.Evaluate("${Namespace}")
  Do tInstaller.PushNS("%SYS")
  Do ##class(Security.System).GetInstallationSecuritySetting(.security)
  If (security="None") {
    Set cspProperties("AutheEnabled") = $$$AutheUnauthenticated
  } Else {
    Set cspProperties("AutheEnabled") = $$$AutheCache // Password
  }
  Set cspName = "/restapi"
  Set cspProperties("NameSpace") = $Get(Namespace,"SFTPLOG")
  Set cspProperties("Enabled") = 1
  Set cspProperties("DeepSeeEnabled") = 1
  Set cspProperties("iKnowEnabled") = 0
  Set cspProperties("DispatchClass") = "User.REST"
  Set cspProperties("Resource") = ""
  Set cspProperties("ServeFiles") = 1
  Set tSC = ##class(Security.Applications).Create(cspName,.cspProperties)
  Do tInstaller.PopNS()
  If $$$ISERR(tSC) Throw ##class(%Installer.Exception).CreateFromStatus(tSC)
  Quit $$$OK
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

}
