<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
<form action="#cgi.script_name#" method="post">
	#oWriter.write(fieldType="checkbox",stForm="#o#",fieldName="keyformgroupform",optionData="form")#

	<div class="formcontrols">
	<input type="submit" name="submit" value="Save">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="formgroupid" value="#o.formgroupid#">
	<input type="hidden" name="type" value="formgroup">
	<input type="hidden" name="action" value="configure">
	</div>
</form>
</cfoutput>