<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
<form action="#cgi.script_name#" method="post">
	#oWriter.write(fieldType="radio",stForm="#o#",fieldName="organizationstatus",optionData="organizationstatus")#

	<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="organizationid" value="#o.organizationid#">
	<input type="hidden" name="type" value="organization">
	<input type="hidden" name="action" value="configure">
	</div>
</form>
</cfoutput>