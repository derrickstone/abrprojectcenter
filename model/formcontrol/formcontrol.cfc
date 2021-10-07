<cfcomponent>
	<!---
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


	<!--- set the current value of this item --->
	<cfif len(arguments.value) eq 0>
		<!--- if the item is a not a checkbox, which requires a key value for a many to many relationship, just get the saved value --->
		<cfif structkeyexists(stForm,arguments.fieldName) and 
			not listfindnocase("3,5,checkbox",arguments.fieldType)>
		
			<cfset arguments.value = stForm[arguments.fieldName]>
		<cfelseif arguments.fieldType eq 5>
			<!--- this is a checkbox multiple selector
				if the item is a generated form question, we look up the
				value in the optiondata table --->
			
			<cfset arguments.fieldName = "f_" & arguments.formfieldid>
			<cfinvoke component="#application.modelpath#.optiondata" method="getOptionData" returnvariable="arguments.value" formfieldid="#arguments.formfieldid#" optionset="#arguments.optionset#" sortOrder="#arguments.sortOrder#"></cfinvoke>

			<!--- set the looked up value to the arguments.value field --->
			<cfset arguments.value=currentValue>
		<cfelseif arguments.fieldType eq "checkbox">
			<!--- this item is a system form, not a generated form object,
				so we have to look up the value in the appropriate key table.
				We deduce this table name from the name of the field. For example,
				keyusrorganization is a key table matching up usr and organization entities. Type should be the master entity for that getkeyform. If the form allows you to match any number of organizations to a user, that master entity is the user. --->
			<cfinvoke component="#application.modelpath#.object" method="getKeyValues" returnvariable="arguments.value" pkfield="#arguments.stForm.type#" pkvalue="#arguments.stForm["#arguments.stForm.type#id"]#" datatable="#arguments.fieldName#" sortOrder="#arguments.sortOrder#" datafield="#arguments.optiondata#"></cfinvoke>
		<cfelseif arguments.fieldType eq "3">
			
			<cfif len(arguments.stResponse.filepath)>
				<cfinvoke component="#application.modelpath#.fileattachment" method="geturl" returnvariable="targetpath" responseset="#arguments.stResponse.responseset#" formfield="#arguments.formfieldid#"></cfinvoke>

				<cfset arguments.value = '<div><a href="#targetpath#/#arguments.stResponse.filepath#" target="_blank">#arguments.stResponse.filepath#</a><div>'>
			</cfif>
		</cfif>

	</cfif>

	<!---<cfif isnumeric(arguments.formfieldid)>
		<cfquery name="qFormField" >
		select * from formfield where formfieldid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfieldid#">
		</cfquery>
	</cfif>--->

	<!--- get options, if required 
		instead of this explicit list, perhaps we should use something else...--->
	<cfif listfindnocase ("4,5",arguments.fieldtype)>
		<!--- most common case, an option set is being specified
			one of the user's option sets--->
		<cfinvoke component="#application.modelpath#.optionset" method="getOptions" optionsetid="#arguments.optionset#" returnvariable="qOptions" abbrcolumn="#arguments.abbrcolumn#"></cfinvoke>
	<cfelseif arguments.fieldType eq 6>
		<cfinvoke component="#application.modelpath#.object" method="getData" type="yesno" returnvariable="qOptions" abbrcolumn="#arguments.abbrcolumn#"></cfinvoke>

	<cfelseif listfindnocase("options,checkbox,selector,radio",arguments.fieldType)>

		<!--- hmm - caching? --->
			
			
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
		<cfelseif arguments.fieldtype eq "yesno" or arguments.fieldtype eq "6">
			<cfinvoke component="#application.modelpath#.object" method="getData" type="yesno" returnvariable="qOptions" sortorder="#arguments.sortorder#">
		<cfelse>
			Error! Form controls with options must specify a source for optionData or supply a formFieldId.<cfabort>
		</cfif>

	</cfif>
<!---
	<cfswitch expression="#arguments.targetcolumn#">
		<cfcase value="n">
			<cfset t = "numericresponse">
		</cfcase>
		<cfcase value="t">
			<cfset t ="textresponse">
		</cfcase>
		<cfcase value="f">
			<cfset t = "filepath">
		</cfcase>
		<cfdefaultcase>
			<cfset t = "stringresponse">
		</cfdefaultcase>
	</cfswitch>
--->

	<!--- construct the HTML control --->

	<cfswitch expression="#arguments.fieldType#">
		<cfcase value="5">
			<cfif left(arguments.fieldName,3) neq "key">
				Error! Checkboxes must use a key table to store data.<cfabort>
			</cfif>
			<cfif arguments.value eq "" and arguments.defaultvalue neq "">
				<Cfset arguments.value = arguments.defaultvalue>
			</Cfif>

			<cfset sReturn = sReturn & '<span id="#arguments.fieldName#">'>
			<cfif qOptions.recordcount gt 0>
				<cfloop query="qOptions">
					<cfset sReturn = sReturn & '<input type="checkbox" name="f-#arguments.formfieldid#" id="#arguments.htmlid#ck_#qOptions.id#" value="#qOptions.id#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)#'>
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
		</cfcase>
		<cfcase value="options,checkbox">
			<cfif left(arguments.fieldName,3) neq "key">
				Error! Checkboxes must use a key table to store data.<cfabort>
			</cfif>

			<cfif arguments.value eq "" and arguments.defaultvalue neq "">
				<Cfset arguments.value = arguments.defaultvalue>
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
		</cfcase>
		<cfcase value="4,6"> <!--- radio or yesno --->
			<!---<cfif len(arguments.optionData) eq 0>
				Error! Radio button types must specify a source for option data.<cfabort>
			</cfif>--->
			<cfset arguments.value = arguments.stResponse[t]>

			<cfif arguments.value eq "" and arguments.defaultvalue neq "">
				<Cfset arguments.value = arguments.defaultvalue>
			</Cfif>

			<cfif qOptions.recordCount lte 10 and qOptions.recordCount gt 0>
				<cfset sReturn = sReturn & '<span id="#arguments.fieldName#"><label for="#arguments.fieldName#">#getLabel(arguments.fieldName)#</label>'>
				<cfloop query="qOptions">
					<cfset sReturn = sReturn & '<input name="f-#arguments.targetcolumn#-#arguments.formfieldid#" type="radio" value="#qOptions.id#" id="#arguments.htmlid#rd_#qOptions.id#" #drawDisabled(arguments.readonly)# #drawRequired(arguments.required)#'>
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
			<cfelseif qOptions.recordCount gt 10>
				<cfset sReturn = sReturn & '<span id="#arguments.htmlid##arguments.fieldName#"><label for="#arguments.fieldName#">#getLabel(arguments.fieldName)#</label><select name="f-#arguments.targetcolumn#-#arguments.formfieldid#" #drawDisabled(arguments.readonly)# #drawRequired(arguments.required)#>'>
				<cfloop query="qOptions">
					<cfset sReturn = sReturn & '<option  value="#qOptions.id#"  #drawReadOnly(arguments.readonly)# #drawRequired(arguments.required)#'>
					<cfif qOptions.id eq arguments.value>
						<cfset sReturn = sReturn & ' selected '>
					</cfif>
					<cfset sReturn = sReturn & '> #qOptions.name#</option>'>
				</cfloop>
				<cfset sReturn = sReturn & '</select></span>'>
			<cfelse>
				<cfset sReturn = "I'm sorry, there currently are no options to select.">
			</cfif>
		</cfcase>
		<cfcase value="radio,yesno">
			<!---<cfif len(arguments.optionData) eq 0>
				Error! Radio button types must specify a source for option data.<cfabort>
			</cfif>--->
			<cfif arguments.value eq "" and arguments.defaultvalue neq "">
				<Cfset arguments.value = arguments.defaultvalue>
			</Cfif>

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
		
		</cfcase>
		<cfcase value="selector">
		
			<cfset sReturn = sReturn & '<span id="#arguments.htmlid##arguments.fieldName#"><label for="#arguments.fieldName#">#getLabel(arguments.fieldName)#</label><select name="#arguments.fieldName#" #drawDisabled(arguments.readonly)# #drawRequired(arguments.required)#>'> 

				<cfif arguments.required neq true>
					<Cfset sReturn = sReturn & '<option value="0">Default</option>'>
				</cfif>

				<cfloop query="qOptions">
					<cfset sReturn = sReturn & '<option  value="#qOptions.id#"'>
					<cfif qOptions.id eq arguments.value>
						<cfset sReturn = sReturn & ' selected '>
					</cfif>
					<cfset sReturn = sReturn & '> #qOptions.name#</option>'>
				</cfloop>
				<cfset sReturn = sReturn & '</select></span>'>

		</cfcase>
		<cfcase value="1"> <!--- text input --->

			<!--- default to the specified default value, if the form has not been saved --->
			<cfif arguments.value eq "" and arguments.defaultvalue neq "" and arguments.stResponse.datecreated eq "">
				<!--- special case for text input to allow a system variable to be use as the default --->
				<cfif len(arguments.defaultvalue) gt 2 and left(arguments.defaultvalue,2) eq "||">
					<Cfset arguments.value = evaluate("#right(arguments.defaultvalue,len(arguments.defaultvalue)-2)#")>
				<cfelse>
					<Cfset arguments.value = arguments.defaultvalue>
				</Cfif>
			<cfelse>
				<cfset arguments.value = arguments.stResponse[t]>
			</Cfif>
			
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><input type="text" name="f-#arguments.targetcolumn#-#arguments.formfieldid#" id="#arguments.htmlid##arguments.fieldName#" value="#arguments.value#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)# placeholder="#arguments.placeholder#">'>
		</cfcase>
		<cfcase value="10"> <!--- long text, single line --->
			<!--- default to the specified default value, if the form has not been saved --->
			<cfif arguments.value eq "" and arguments.defaultvalue neq "" and arguments.stResponse.datecreated eq "">
				<Cfset arguments.value = arguments.defaultvalue>
			<cfelse>
				<cfset arguments.value = arguments.stResponse[t]>
			</Cfif>
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><div><input type="text" name="f-#arguments.targetcolumn#-#arguments.formfieldid#" id="#arguments.htmlid##arguments.fieldName#" value="#arguments.value#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)# placeholder="#arguments.placeholder#" class="wide"></div>'>
		</cfcase>
		<cfcase value="11"> <!--- date --->
			<!--- default to the specified default value, if the form has not been saved --->
			<cfif arguments.value eq "" and arguments.defaultvalue neq "" and arguments.stResponse.datecreated eq "">
				<Cfset arguments.value = arguments.defaultvalue>
			<cfelse>
				<cfset arguments.value = arguments.stResponse[t]>
			</Cfif>
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><div><input type="date" name="f-#arguments.targetcolumn#-#arguments.formfieldid#"  id="#arguments.htmlid##arguments.fieldName#" value="#arguments.value#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)# placeholder="#arguments.placeholder#" ></div>'>
		</cfcase>
		<cfcase value="textInput">
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><input name="#arguments.fieldName#" id="#arguments.htmlid##arguments.fieldName#" value="#arguments.value#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)# placeholder="#arguments.placeholder#">'>
		</cfcase>
		<cfcase value="2">
			<!--- default to the specified default value, if the form has not been saved --->
			<cfif arguments.value eq "" and arguments.defaultvalue neq "" and arguments.stResponse.datecreated eq "">
				<Cfset arguments.value = arguments.defaultvalue>
			<cfelse>
				<cfset arguments.value = arguments.stResponse[t]>
			</Cfif>
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><textarea name="f-#arguments.targetcolumn#-#arguments.formfieldid#" id="#arguments.htmlid##arguments.fieldName#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)#>#arguments.value#</textarea>'>
		</cfcase>
		<cfcase value="textArea">
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><textarea name="#arguments.fieldName#" id="#arguments.htmlid##arguments.fieldName#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)#>#arguments.value#</textarea>'>
		</cfcase>
		
		<cfcase value="contentblock">
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><textarea name="#arguments.fieldName#" id="#arguments.htmlid##arguments.fieldName#" #drawReadonly(arguments.readonly)# #drawRequired(arguments.required)#>#arguments.value#</textarea>'>
		</cfcase>
		<cfcase value="7,approval">
			<!---<cfinvoke component="#application.modelpath#.approval" method="drawApprovalForm" returnvariable="sReturn" label="#arguments.fieldName#" formfieldid="#arguments.formfieldid#">--->
				<cfset sReturn = '<input type="hidden" name="a-#arguments.formfieldid#">'>
			
		</cfcase>
		<cfcase value="8">
			<cfset arguments.value = arguments.stResponse[t]>
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label><div id="#arguments.htmlid##arguments.fieldName#" >#arguments.value#</div>'>
		</cfcase>
		<cfcase value="9">
			<cfset arguments.value = arguments.stResponse[t]>
			<cfset sReturn = '<label for="#arguments.htmlid##arguments.fieldName#">#getLabel(arguments.fieldName)#</label>'>
		</cfcase>
		<cfcase value="3"><!--- file upload field --->
			<!--- file field - list the current file as a hyperlink --->

			<cfif len(arguments.value)>
				
				<cfset sReturn = '<div>#arguments.value#<div>'>
			<cfelse>
				<cfset sReturn = '<div><em>No file attached.</em></div>'>
			</cfif>
			<cfif arguments.readonly neq true>
				<cfset sreturn = sreturn & '<input type="file" name="file-#arguments.formfieldid#" id="#arguments.htmlid#" #drawRequired(arguments.required)# >'>
			</cfif>
		</cfcase>
	</cfswitch>

	<cfreturn sReturn>
</cffunction>
--->
<cffunction name="drawDisabled">
	<cfargument name="value">
	<cfset var sReturn = "">
	<cfif (arguments.value eq true)>
		<Cfset sReturn = 'disabled="disabled"'>
	</cfif>
	<Cfreturn sReturn>
</cffunction>
<cffunction name="drawReadOnly">
	<cfargument name="value">
	<cfset var sReturn = "">
	<cfif (arguments.value eq true)>
		<Cfset sReturn = 'readonly="readonly"'>
	</cfif>
	<Cfreturn sReturn>
</cffunction>
<cffunction name="drawRequired">
	<cfargument name="value">
	<cfset var sReturn = "">
	<cfif (arguments.value eq "true")>
		<Cfset sReturn = 'required="required"'>
	</cfif>
	<Cfreturn sReturn>
</cffunction>
<cffunction name="getLabel">
	<cfargument name="fieldName">

	<cfset var qGet = "">
	<cfset var sReturn = "">

	<!--- adding some cache --->

	<cfif structkeyexists(application,"stLabel") eq false or url.reset eq 1>
		<cflock scope="application" type="exclusive" timeout="10">
			<cfset application.stLabel = structnew()>
		</cflock>
	</cfif>

	<cfif structkeyexists(application.stLabel,arguments.fieldName)>
		<cfset sReturn = application.stLabel[arguments.fieldName]>
	<cfelse>
		<cfquery name="qGet"  cachedwithin="#createtimespan(0,1,0,0)#"><!--- cached one hour --->
		select fieldLabel from fieldLabel where fieldName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldName#">
		</cfquery>
		<cfif qGet.recordcount gt 0>			
			<cfset sReturn = qGet.fieldLabel>
		<cfelse>
			<Cfset sReturn = arguments.fieldName>
		</Cfif>
		<cflock scope="application" type="exclusive" timeout="10">
			<cfset application.stLabel[arguments.fieldName] = sReturn>
		</cflock>
	</cfif>
	<cfreturn sReturn>
</cffunction>
</cfcomponent>