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

	<cfinvoke component="#application.modelpath#.formfield" method="getformfieldtargetcolumn" formfieldid="#arguments.formfieldid#" returnvariable="t"></cfinvoke>

	<!--- set the current value of this item --->
	<!---<cfif len(arguments.value) eq 0>--->
		<!--- if the item is a not a checkbox, which requires a key value for a many to many relationship, just get the saved value --->
	
		<cfset arguments.fieldLabel=arguments.fieldName>
		<cfset arguments.fieldName = "k-" & arguments.formfieldid>
		<cfinvoke component="#application.modelpath#.optiondata" method="getOptionData" returnvariable="arguments.value" formfieldid="#arguments.formfieldid#" responsesetid="#arguments.stResponse.responseset#" responsedataid="#arguments.stResponse.responsedataid#" sortOrder="#arguments.sortOrder#"></cfinvoke>

		<!--- set the looked up value to the arguments.value field --->
		<!---<cfset arguments.value=currentValue>--->

		<cfinvoke component="#application.modelpath#.optionset" method="getOptions" optionsetid="#arguments.optionset#" returnvariable="qOptions" abbrcolumn="#arguments.abbrcolumn#"></cfinvoke>
		
		<!---<cfif arguments.value eq "" and arguments.defaultvalue neq "">
			<Cfset arguments.value = arguments.defaultvalue>
		</Cfif>--->
	<!---</Cfif>--->
	<cfset sReturn = sReturn & '<label for="#arguments.htmlid##arguments.fieldName#">#arguments.fieldLabel#</label><span id="#arguments.fieldName#">'>
	<cfif qOptions.recordcount gt 0>
		<cfloop query="qOptions">
			<cfset idname="#arguments.htmlid#ck_#qOptions.id#">
			<cfset sReturn = sReturn & '<input type="checkbox" name="k-#arguments.formfieldid#" id="#idname#" value="#qOptions.id#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)#'>
			<cfif listfindnocase(arguments.value,qOptions.id)>
				<cfset sReturn = sReturn & " checked ">
			</cfif>
			
			<cfif len(arguments.abbrcolumn)>
				<cfset sReturn = sReturn & '> <label for="#idname#"><abbr title="#qOptions.abbrcolumn#">#qOptions.name#</abbr></label>'>
			<cfelse>
				<cfset sReturn = sReturn & '> <label for="#idname#">#qOptions.name#</label>'>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset sReturn = sReturn & "I'm sorry, there are currently no options to select.">
	</cfif>	
	<cfset sReturn = sReturn & '</span>'>


	<cfreturn sReturn>
</cffunction>

</cfcomponent>