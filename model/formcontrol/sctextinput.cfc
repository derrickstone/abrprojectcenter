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

	<!---<cfif len(arguments.value) eq 0>
		<cfset arguments.value = stForm[arguments.fieldName]>
	</cfif>--->

	<!--- default to the specified default value, if the form has not been saved --->
	<cfif arguments.value eq "" and arguments.defaultvalue neq "" and arguments.stResponse.datecreated eq "">
		<!--- special case for text input to allow a system variable to be use as the default --->
		<cfif len(arguments.defaultvalue) gt 2 and left(arguments.defaultvalue,2) eq "||">
			<Cfset arguments.value = evaluate("#right(arguments.defaultvalue,len(arguments.defaultvalue)-2)#")>
		<cfelse>
			<Cfset arguments.value = arguments.defaultvalue>
		</Cfif>
	<cfelse>
		<cfinvoke component="#application.modelpath#.formfield" method="getformfieldtargetcolumn" formfieldid="#arguments.formfieldid#" returnvariable="t"></cfinvoke>
		<cfset arguments.value = arguments.stResponse[t]>
	</Cfif>
	
	<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><input type="text" name="f-#arguments.formfieldid#" id="#arguments.htmlid##arguments.fieldName#" value="#arguments.value#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)# placeholder="#arguments.placeholder#">'>

	<cfreturn sReturn>
	</cffunction>
</cfcomponent>