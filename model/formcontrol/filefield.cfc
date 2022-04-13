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
	<cfset var qFiles="">

	<!---
	<cfif isstruct(arguments.stResponse) and len(arguments.stResponse.filepath)>
		<cfinvoke component="#application.modelpath#.fileattachment" method="geturl" returnvariable="targetpath" responseset="#arguments.stResponse.responseset#" formfield="#arguments.formfieldid#"></cfinvoke>

		<cfset arguments.value = '<div><a href="#targetpath#/#arguments.stResponse.filepath#" target="_blank">#arguments.stResponse.filepath#</a><div>'>
	</cfif>
--->
	<!--- get any files attached to this form field --->
	<cfinvoke component="#application.modelpath#.fileattachment" method="getFilesForObject" returnvariable="qFiles" type="#arguments.stForm.type#" pkid="#arguments.stForm['#arguments.stForm.type#id']#" fieldname="#arguments.fieldname#"></cfinvoke>
	<cfset sFileList="">
	<cfif isquery(qFiles)>
		<cfloop query="qFiles">
			<cfset sFileList=sFileList&"<div><a href='"&qFiles.filepath&"'>"&qfiles.originalfilename&"</a> </div>"><!---<a href=''>[ x ]</a>--->
		</cfloop>
	</cfif>

	<cfif len(sFileList)>				
		<cfset sReturn = '<div>#sFileList#<div>'>
	<cfelse>
		<cfset sReturn = '<div><em>No file attached.</em></div>'>
	</cfif>
	<cfif arguments.readonly neq true>
		<cfset sreturn = sreturn & '<input type="file" name="#arguments.fieldname#" id="#arguments.htmlid#" #drawRequired(arguments.required)# >'>
	</cfif>

	<cfreturn sReturn>
</cffunction>
</cfcomponent>