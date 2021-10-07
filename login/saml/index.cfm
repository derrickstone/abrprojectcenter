<!--- this folder must be set to require a saml session 
the login process should set the remote_user variable to match the uid --->

<cfinvoke component="#application.modelpath#.usr" method="samllogin" returnvariable="token">

<cfif len(token)>
	
	<!--- may need to check for spoofing here --->
	<cfinvoke component="#application.modelpath#.usr" method="init" returnvariable="u" usrname="#cookie.usrname#" token="#token#">

	<cflock scope="session" type="exclusive" timeout="10">
		<Cfset session.usr = u>
	</cflock>
	Getting you logged in...

	<cflocation url="/index.cfm" addtoken="no">
<cfelse>
	I'm sorry, something went wrong.
</Cfif>