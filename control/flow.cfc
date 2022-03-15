<cfcomponent>
	<cffunction name="handleForm">
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
			<cfif structkeyexists(form,"submit") and ( form.submit eq "submit" or form.submit eq "Save")>
				<cfif isdefined("form.#form.type#id") and isnumeric(form["#form.type#id"]) >	
					<cfinvoke component="#application.modelpath#.object" method="handleEditForm" formdata="#form#" returnvariable="newid" returnnewid="true"></cfinvoke>	
					<cflocation url="#cgi.script_name#?action=configure&#form.type#id=#newid#&type=#form.type#" addtoken="no">
				</cfif>
			<cfelse>
				<cflocation url="#cgi.SCRIPT_NAME#" addtoken="no">
			</cfif>	
		</cfif>
	<cfelseif url.action eq "delete">
		<cfif isdefined ("url.type") and len(url.type)>
		
		<cfinvoke component="#application.modelpath#.#url.type#" method="delete"  id="#url["#url.type#id"]#" returnvariable="sMessage" type="#url.type#"></cfinvoke>
		</cfif>
	<cfelseif url.action eq "configure">
		<cfif isdefined("url.type") and len(url.type)>
			<cfif isdefined("form.submit") and (form.submit eq "Save" or form.submit eq "Submit")>
				<!--- set a default for the target column --->
				<cfif structkeyexists(form,"targetcolumn") eq false and structkeyexists(form,"fieldtype") eq true and isnumeric(form.fieldtype)>
					<cfinvoke component="#application.modelpath#.formfield" method="getdefaulttargetcolumn" formfieldtypeid="#form.fieldtype#" returnvariable="tc"></cfinvoke>
					<cfset form.targetcolumn = tc>
				</cfif> 
				<cfinvoke component="#application.modelpath#.#url.type#" method="handleEditForm" formdata="#form#" returnvariable="sMessage"></cfinvoke>
			<cfelseif isdefined("form.submit") and form.submit eq "Delete">
				
				<cfinvoke component="#application.modelpath#.#form.type#" method="delete" formdata="#form#" returnvariable="sMessage" id="#form['#form.type#id']#" type="#form.type#"></cfinvoke>
			<cfelse>
				<!--- space for debugging --->

			</cfif>
			<cfif isdefined("form.cancel")>
				<cflocation url="#cgi.SCRIPT_NAME#" addtoken="no">
			</cfif>
			
			<cfinvoke component="#application.modelpath#.#url.type#" method="configureForm" id="#url["#url.type#id"]#" returnvariable="sConfigureForm" formdata="#form#"></cfinvoke>
			
			<cfoutput>#sConfigureForm#</cfoutput>
			<!--- I think it makes sense to not also draw the form editing form on this page --->
			<cfabort>
		</cfif>
	</cfif>
</cfif>			
<cfreturn sMessage>
<!--- END handle form submissions --->
	</cffunction>
</cfcomponent>