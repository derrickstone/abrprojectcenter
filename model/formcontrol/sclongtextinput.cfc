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
	<cfset var t = "">

	<cfinvoke component="#application.modelpath#.formfield" method="getformfieldtargetcolumn" formfieldid="#arguments.formfieldid#" returnvariable="t"></cfinvoke>

	<cfif arguments.value eq "" and arguments.defaultvalue neq "" and arguments.stResponse.datecreated eq "">
		<Cfset arguments.value = arguments.defaultvalue>
	<cfelse>
		<cfset arguments.value = arguments.stResponse[t]>
	</Cfif>
	<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><div><input type="text" name="f-#arguments.formfieldid#" id="#arguments.htmlid##arguments.fieldName#" value="#arguments.value#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)# placeholder="#arguments.placeholder#" class="wide"></div>'>

	<cfreturn sReturn>
</cffunction>
</cfcomponent>