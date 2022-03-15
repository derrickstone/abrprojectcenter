<cfcomponent extends="formcontrol">
<cffunction name="draw" output="true">
	<cfargument name="fieldType">
	<cfargument name="fieldName">
	<cfargument name="fieldLabel" default="">
	<cfargument name="value" default="">
	<cfargument name="stForm">
	<cfargument name="optionData">
	<cfargument name="optionSet" default="">
	<cfargument name="sortOrder" default="">
	<cfargument name="formFieldId" default="">
	<cfargument name="readonly" default="false">
	<cfargument name="required" default="false">
	<cfargument name="placeholder" default="">
	<cfargument name="htmlid" default="">
	<cfargument name="abbrcolumn" default="">
	<cfargument name="targetcolumn" default="s">
	<cfargument name="stResponse" default="">
	<cfargument name="defaultvalue" default="">

	<cfset var sReturn = "">
	<cfset var qOptions = "">
	<cfset var qKeyData = "">
	<cfset var qFormField = "">
	<cfset var t = "">



	<!--- fix for htmlid --->
	<cfif arguments.htmlid eq "">
		<cfset arguments.htmlid = arguments.fieldName>
	</cfif>

	<!--- set the current value of this item --->
	<cfif len(arguments.value) eq 0>
		<!--- if the item is a not a checkbox, which requires a key value for a many to many relationship, just get the saved value --->
		
		
		<!--- this item is a system form, not a generated form object,
			so we have to look up the value in the appropriate key table.
			We deduce this table name from the name of the field. For example,
			keyusrorganization is a key table matching up usr and organization entities. Type should be the master entity for that getkeyform. If the form allows you to match any number of organizations to a user, that master entity is the user. --->


		<cfif isQuery(arguments.optionData)>
			<!--- if a query is supplied, just use it --->
			<cfset qOptions = arguments.optionData>	
			<cfinvoke component="#application.modelpath#.object" method="getKeyValues" returnvariable="arguments.value" pkfield="#arguments.stForm.type#" pkvalue="#arguments.stForm["#arguments.stForm.type#id"]#" datatable="#arguments.fieldName#" sortOrder="#arguments.sortOrder#" datafield="#arguments.optiondata#"></cfinvoke>
		<cfelseif len(arguments.optionData)> 
			<!--- using a String, a type is being specified --->
			<cfinvoke component="#application.modelpath#.object" method="getKeyValues" returnvariable="arguments.value" pkfield="#arguments.stForm.type#" pkvalue="#arguments.stForm["#arguments.stForm.type#id"]#" datatable="#arguments.fieldName#" sortOrder="#arguments.sortOrder#" datafield="#arguments.optiondata#"></cfinvoke>
			<cfinvoke component="#application.modelpath#.object" method="getData" type="#arguments.optionData#" returnvariable="qOptions" sortorder="#arguments.sortorder#">
			<cfif len(arguments.abbrcolumn)>
				<cfinvokeargument name="lAdditionalFields" value="#arguments.abbrcolumn# as abbrcolumn">
			</cfif>
			</cfinvoke>
		<cfelseif arguments.fieldtype eq "yesno" or arguments.fieldtype eq "6">
			<cfinvoke component="#application.modelpath#.object" method="getData" type="yesno" returnvariable="qOptions" sortorder="#arguments.sortorder#">
		<cfelse>
			Error! Form controls with options must specify a source for optionData or supply a formFieldId.<cfabort>
		</cfif>
		<cfif left(arguments.fieldName,3) neq "key">
			Error! Checkboxes must use a key table to store data.<cfabort>
		</cfif>

		<cfif arguments.value eq "" and arguments.defaultvalue neq "">
			<Cfset arguments.value = arguments.defaultvalue>
		</Cfif>			
	</Cfif>
	<cfset sReturn = sReturn & '<span id="#arguments.fieldName#">'>
	<cfif qOptions.recordcount gt 0>
		<cfloop query="qOptions">
			<cfset sReturn = sReturn & '<input type="checkbox" name="#arguments.fieldName#" id="#arguments.htmlid#ck_#qOptions.id#" value="#qOptions.id#" #drawDisabled(arguments.readonly)# #drawRequired(arguments.required)#'>
			<cfif listfindnocase(arguments.value,qOptions.id)>
				<cfset sReturn = sReturn & " checked ">
			</cfif>
			
			<cfif len(arguments.abbrcolumn)>
				<cfset sReturn = sReturn & '> <label for="#arguments.htmlid#ck_#qOptions.id#"><abbr title="#qOptions.abbrcolumn#">#qOptions.name#</abbr></label>'>
			<cfelse>
				<cfset sReturn = sReturn & '> <label for="#arguments.htmlid#ck_#qOptions.id#">#qOptions.name#</label>'>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset sReturn = sReturn & "I'm sorry, there are currently no options to select.">
	</cfif>	
	<cfset sReturn = sReturn & '</span><label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label>'>

	<cfreturn sReturn>
</cffunction>
</cfcomponent>