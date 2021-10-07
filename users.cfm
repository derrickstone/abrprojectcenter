<!--- control access to the form --->
<cfif session.usr.accesslevel gt 1>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<!--- handle form submissions --->
<cfset sMessage = "">
<cfif ( isdefined("form.action") and len(form.action) ) and (not isdefined("url.action") or len(url.action) eq 0) >
	<cfset url.action = form.action>
</cfif>	
<cfif ( isdefined("form.type") and len(form.type) ) and (not isdefined("url.type") or len(url.type) eq 0) >
	<cfset url.type = form.type>
	<cfset url[url.type&"id"]=form[url.type&"id"]>
</cfif>

<cfif isdefined("url.action") and len(url.action) >
	<cfif url.action eq "edit">
		<cfif isdefined("form.type") and len(form.type)>
			<cfif structkeyexists(form,"submit") and form.submit eq "save">
				<cfif isdefined("form.#form.type#id") and isnumeric(form["#form.type#id"]) >
					<cfinvoke component="#application.modelpath#.object" method="handleEditForm" formdata="#form#" returnvariable="sMessage"></cfinvoke>	
				</cfif>
			<cfelse>
				<cflocation url="#cgi.SCRIPT_NAME#" addtoken="no">
			</cfif>	
		</cfif>
	<cfelseif url.action eq "delete">
		<cfif isdefined ("url.type") and len(url.type)>
		
		<cfinvoke component="#application.modelpath#.object" method="delete" type="#url.type#" id="#url["#url.type#id"]#" returnvariable="sMessage"></cfinvoke>
		</cfif>
	<cfelseif url.action eq "configure">
		<cfif isdefined("url.type") and len(url.type)>
			<cfif isdefined("form.submit") and form.submit eq "submit">

				<cfif session.usr.accesslevel lte 2 and structkeyexists(form,"keyusroptiondata") eq false>
					<cfset form.keyusroptiondata="">
				</cfif>
				<cfinvoke component="#application.modelpath#.#url.type#" method="handleEditForm" formdata="#form#" returnvariable="sMessage"></cfinvoke>
			</cfif>
			<cfif isdefined("form.cancel")>
				<cflocation url="#cgi.SCRIPT_NAME#" addtoken="no">
			</cfif>
			<cfinvoke component="#application.modelpath#.#url.type#" method="configureForm" id="#url["#url.type#id"]#" returnvariable="sConfigureForm" formdata="#form#"></cfinvoke>
			<cfoutput>#sConfigureForm#</cfoutput>
			<cfabort>
		</cfif>
	</cfif>
</cfif>			
<cfif len(sMessage)>
	<cfoutput>
	<p class="userfeedback">#sMessage#</p>
	</cfoutput>
</cfif>


<cfinvoke component="#application.modelpath#.usr" method="getData" returnvariable="qUsr"></cfinvoke>

<cfinvoke component="#application.modelpath#.usr" method="showEditingList" returnvariable="sEditUsrList" qData="#qUsr#"></cfinvoke>
<cfoutput>#sEditUsrList#</cfoutput>


<br />
<a href="index.cfm">[ Return ]</a>