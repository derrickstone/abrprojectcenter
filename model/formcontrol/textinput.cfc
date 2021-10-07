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
	
	<cfset arguments.value = stForm[arguments.fieldName]>

	<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><input type="text" name="#arguments.fieldName#" id="#arguments.htmlid##arguments.fieldName#" value="#arguments.value#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)# placeholder="#arguments.placeholder#">'>

	<cfreturn sReturn>
</cffunction>
</cfcomponent>