<cfset oWriter = createObject("component", application.modelpath&".form")>

<cfif structkeyexists(request,"formstatus") and isnumeric(request.formstatus)>
	<cfif request.formstatus gt 2>
		<cfset readonly=true>
	<cfelse>
		<cfset readonly=false>
	</cfif>
</cfif>
<cfoutput>
<A name="#arguments.anchor#"></A>
<form action="#cgi.SCRIPT_NAME#?type=form&formid=#url.formid#&action=configure###arguments.anchor#" method="post">

	<cfif arguments.id eq -1>
		<cfset sPlaceholder="New Field Label">
	<cfelse>
		<cfset sPlaceholder="">
	</cfif>
	#oWriter.write(fieldtype="textInput",fieldName="label",stForm=o,placeholder=sPlaceholder,htmlid=arguments.id,readonly=readonly)#

	<cfif o.fieldtype eq "" or o.fieldtype eq 0>
		<Cfset o.fieldtype =1>
	</Cfif>
	
	#oWriter.write(fieldtype="radio",fieldName="fieldType",stForm=o,optionData="formFieldType",htmlid="t"&arguments.id,sortOrder="sortKey",abbrcolumn="shortdescription",readonly=readonly)#
	<!--- all approvals are required --->
	<cfif o.fieldType neq 7>
		<cfif o.required eq "">
			<Cfset o.required = 0>
		</cfif>
		#oWriter.write(fieldtype="radio",fieldName="required",stForm=o,optionData="yesno",htmlid="r"&arguments.id,readonly=readonly)#
	<cfelse>
		<cfset o.required = 1>
		#oWriter.write(fieldtype="radio",fieldName="required",stForm=o,optionData="yesno",htmlid="r"&arguments.id,readonly="yes")#
	</cfif>


	<!--- if this record is saved and a selection is made for option set
		or approval step, show the selector for those items --->
	<cfif structkeyexists(o,"fieldType") and len(o.fieldtype)>
		<cfif o.fieldType eq 4 or o.fieldType eq 5 or o.fieldType eq "radio"><!--- radio, checkbox --->
			#oWriter.write(fieldtype="radio",fieldName="optionSet",stForm=o,optionData="optionset",htmlid="o"&arguments.id,readonly=readonly)#
			<!---<input type="hidden" name="targetcolumn" value="numericresponse">--->
			<cfif len(o.optionset)>
				<cfinvoke component="#application.modelpath#.optiondata" method="getdata" optionsetid="#o.optionset#" returnvariable="qOS"></cfinvoke>
			#oWriter.write(fieldtype="selector",fieldname="defaultvalue",stForm=o,optionData="#qOS#",htmlid="dv"&arguments.id,readonly=readonly)#
			<cfelse>
				<span class="dim">Please select the set of options you would like to use for this question.</span>
				#oWriter.write(fieldtype="textInput",fieldname="defaultvalue",stForm=o,htmlid="dv"&arguments.id,readonly=readonly)#
			</cfif>
		<cfelseif o.fieldType eq 7><!--- approval --->			
			#oWriter.write(fieldtype="radio",fieldName="approvalSet",stForm=o,optionData="approvalSet",htmlid="a"&arguments.id,readonly=readonly)#
		</cfif>

	<!--- this item has been saved, provide for an option to customize the target column --->
		<!--- STUB: is there value in allowing the user to select their save data column?
		#oWriter.write(fieldtype="selector",fieldName="targetcolumn",stForm=o,optionData="targetcolumn",htmlid="tc"&arguments.id)# --->	
		<cfif structkeyexists(o,"targetcolumn") and len(o.targetcolumn)>
			<input type="text" name="targetcolumn" value="#o.targetcolumn#">
		</cfif>
	<!---<cfelse>
		<input type="hidden" name="targetcolumn" value="stringresponse">--->
	</cfif>
	#oWriter.write(fieldtype="textarea",fieldName="fieldcomment",stForm=o,htmlid="fc"&arguments.id,readonly=readonly)#

<!--- STUB: fix this control 
<div>
	<label for="td#arguments.id#">Target Column</label>
	<select name="targetcolumn" id="tc#arguments.id#">
		<option value="s">String</option>
		<option value="n">Number</option>
		<option value="t">Large Text</option>
	</select>
</div>
--->


<!--- STUB: this will need to become a drop down selector --->
<!---
<span class="advanced">
#oWriter.write(fieldtype="selector",fieldName="assignee",fieldLabel="Alternate Assignee",stForm=o,optionData="usr",htmlid="asg"&arguments.id)#
</span> --->

	
	<input type="hidden" name="type" value="#arguments.type#">
	<input type="hidden" name="#arguments.type#id" value="#arguments.id#">
	<input type="hidden" name="action" value="configure">
	<input type="hidden" name="form" value="#url.formid#">
	<cfif structkeyexists(o,"sortkey") and isnumeric(o.sortkey)>
		<input type="hidden" name="sortkey" value="#o.sortkey#">
	</cfif>
<cfif readonly eq false>
	<input type="submit" name="submit" value="Save">
	<input type="submit" name="cancel" value="Cancel">

	<cfif o.formfieldid neq -1>
		<input type="submit" name="submit" value="Delete" onClick="return confirm('Are you sure you want to delete this item?');">
		<cfif isnumeric(arguments.position) and (arguments.position neq 1 and arguments.itemcount neq 1)>
			<input type="submit" name="changeOrder" value="Move Up">
		</cfif>
		<cfif arguments.position neq arguments.itemcount>
			<input type="submit" name="changeOrder" value="Move Down">
		</cfif>
	</cfif>
</cfif>
</form></cfoutput>
