<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
	<a href="forms.cfm">[ Return to List ]</a>
<form action="#cgi.script_name#?type=form&formid=#url.formid#&action=configure" method="post">
	<h2>#o.formname#</h2>
	<div class="post"><h3>Form Settings</h3>

	<!--- show the form grouping option if form groups have been created
	STUB: this is kind of an extra query...  --->
	<cfinvoke component="#application.modelpath#.formgroup" method="getdata" returnvariable="qFormGroups"></cfinvoke>
	<cfif qFormGroups.recordcount gt 0>
		#oWriter.write(fieldType="checkbox",stForm="#o#",fieldName="keyformgroupform",optionData="formgroup" )#
	</cfif>
	<!---STUB: hold on this for the moment
		#oWriter.write(fieldType="checkbox",stForm="#o#",field="keyformorganization",optionData="organization",whereClause="formid=")#--->
	<cfif o.formstatus eq "">
		<cfset o.formstatus = 2>
		<Cfset isconfigured = false>
	<cfelse>
		<cfset isconfigured = true>
	</cfif>
	<cfset request.formstatus = o.formstatus> <!--- this works... maybe sloppy way to pass a value --->
	<cfset fc = "Note: Changing form fields after users have submitted responses to a form will cause a loss of data! Therefore, form fields cannot be changed while a form is made available (not private). ">
	#oWriter.write(fieldType="radio",stForm=o,fieldName="formstatus",optionData="formStatus",fieldcomment=fc,htmlid="fs")#
	<cfset request.formstatus = o.formstatus>
	<cfif o.singlesubmission eq "">
		<cfset o.singlesubmission = 1>
	</cfif>
	#oWriter.write(fieldType="radio",stForm=o,fieldName="singlesubmission",optionData="yesno",htmlid="ss")#

	<cfinvoke component="#application.modelpath#.usr" method="getSuperUsrs" returnvariable="qSuperUsrs"></cfinvoke>

	#oWriter.write(fieldType="selector",stForm=o,fieldName="finalassignee",optionData=qSuperUsrs,required=false,htmlid="mac")#
	</div>
	<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel / Close">
	<input type="hidden" name="formid" value="#o.formid#">
	<input type="hidden" name="type" value="form">
	<input type="hidden" name="action" value="configure">
	</div>
</form>	
	<div>

	<cfinvoke component="#application.modelpath#.form" method="getFormFields" returnvariable="aFields" formid="#o.formid#"></cfinvoke>
	<cfset lastid=0>
	<cfif arraylen(aFields)>
		<h3>Fields</h3>
		<cfloop from="1" to="#arraylen(aFields)#" index="t">
			<cfset lastid=t>
			#oWriter.drawItemForm(id=aFields[t].formfieldid,name=aFields[t].label,type="formfield",position=t,itemcount=arraylen(aFields),form=aFields[t].formfieldid,anchor=lastid)#
		</cfloop>
	</cfif>
	<!--- if this isn't read only --->
	<cfif isnumeric(o.formstatus) and isconfigured and request.formstatus lte 2>
	<h3>+ Add a New Field</h3>
	#oWriter.drawItemForm(id=-1,name="",type="formfield",anchor=lastid+1)#
	</div>
	</cfif>

</cfoutput>