<cfcomponent extends="formcontrol">
<cffunction name="draw">
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

	<cfset arguments.value = stForm[arguments.fieldName]>

	<cfif arguments.value eq "" and arguments.defaultvalue neq "">
		<Cfset arguments.value = arguments.defaultvalue>
	</Cfif>

	<cfif isQuery(arguments.optionData)>
			<!--- if a query is supplied, just use it --->
			<cfset qOptions = arguments.optionData>	
	<cfelseif len(arguments.optionData)> 
		<!--- using a String, a type is being specified --->
		<cfinvoke component="#application.modelpath#.object" method="getData" type="#arguments.optionData#" returnvariable="qOptions" sortorder="#arguments.sortorder#">
		<cfif len(arguments.abbrcolumn)>
			<cfinvokeargument name="lAdditionalFields" value="#arguments.abbrcolumn# as abbrcolumn">
		</cfif>
		</cfinvoke>

	<cfelse>
		Error! Form controls with options must specify a source for optionData or supply a formFieldId.<cfabort>
	</cfif>

	<cfset sReturn = sReturn & '<span id="#arguments.fieldName#"><label for="#arguments.fieldName#">#getLabel(arguments.fieldName)#</label>'>
	<cfloop query="qOptions">
		<cfset sReturn = sReturn & '<input name="#arguments.fieldName#" type="radio" value="#qOptions.id#" id="#arguments.htmlid#rd_#qOptions.id#" #drawDisabled(arguments.readonly)# #drawRequired(arguments.required)#'>
		<cfif qOptions.id eq arguments.value>
			<cfset sReturn = sReturn & ' checked '>
		</cfif>
		
		<cfif len(arguments.abbrcolumn)>
			<cfset sReturn = sReturn & '> <label for="#arguments.htmlid#rd_#qOptions.id#"><abbr title="#qOptions.abbrcolumn#">#qOptions.name#</abbr></label>'>
		<cfelse>
			<cfset sReturn = sReturn & '> <label for="#arguments.htmlid#rd_#qOptions.id#">#qOptions.name#</label>'>
		</cfif>
	</cfloop>
	<cfset sReturn = sReturn & '</span>'>
	<cfreturn sReturn>
</cffunction>
</cfcomponent>