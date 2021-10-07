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

	<cfinvoke component="#application.modelpath#.object" method="getData" type="yesno" returnvariable="qOptions" abbrcolumn="#arguments.abbrcolumn#"></cfinvoke>

	<cfinvoke component="#application.modelpath#.formfield" method="getformfieldtargetcolumn" formfieldid="#arguments.formfieldid#" returnvariable="t"></cfinvoke>

	<cfset arguments.value = arguments.stResponse[t]>

	<cfif arguments.value eq "" and arguments.defaultvalue neq "">
		<Cfset arguments.value = arguments.defaultvalue>
	</Cfif>

	<cfset sReturn = sReturn & '<span id="#arguments.fieldName#"><label for="#arguments.fieldName#">#getLabel(arguments.fieldName)#</label>'>
	<cfloop query="qOptions">
		<cfset sReturn = sReturn & '<input name="f-#arguments.formfieldid#" type="radio" value="#qOptions.id#" id="#arguments.htmlid#rd_#qOptions.id#" #drawDisabled(arguments.readonly)# #drawRequired(arguments.required)#'>
		<!--- should be numericresponse column --->
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