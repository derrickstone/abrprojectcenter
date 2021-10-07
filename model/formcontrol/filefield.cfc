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

	<cfif len(arguments.stResponse.filepath)>
		<cfinvoke component="#application.modelpath#.fileattachment" method="geturl" returnvariable="targetpath" responseset="#arguments.stResponse.responseset#" formfield="#arguments.formfieldid#"></cfinvoke>

		<cfset arguments.value = '<div><a href="#targetpath#/#arguments.stResponse.filepath#" target="_blank">#arguments.stResponse.filepath#</a><div>'>
	</cfif>

	<cfif len(arguments.value)>
				
		<cfset sReturn = '<div>#arguments.value#<div>'>
	<cfelse>
		<cfset sReturn = '<div><em>No file attached.</em></div>'>
	</cfif>
	<cfif arguments.readonly neq true>
		<cfset sreturn = sreturn & '<input type="file" name="file-#arguments.formfieldid#" id="#arguments.htmlid#" #drawRequired(arguments.required)# >'>
	</cfif>

	<cfreturn sReturn>
</cffunction>
</cfcomponent>