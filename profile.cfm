<!--- edit your profile --->

<Cfif isdefined("form") and structkeyexists(form,"usrid")>
	<cfif isdefined("form.submit") and (form.submit eq "Save" or form.submit eq "Submit")>
		<cfinvoke method="handleEditForm" component="#application.modelpath#.usr" formdata="#form#"></cfinvoke>
	</Cfif>

</cfif>
<cfinvoke method="getdata" component="#application.modelpath#.usr" returnvariable="qUsr" id="#session.usr.usrid#"></cfinvoke>

<cfinvoke method="configureform" component="#application.modelpath#.usr" formdata="#structnew()#" id="#session.usr.usrid#" returnvariable="sReturn"></cfinvoke>

<cfoutput>#sReturn#</cfoutput>