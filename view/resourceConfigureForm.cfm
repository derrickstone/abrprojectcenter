<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
<form action="#cgi.script_name#" method="post">
	#oWriter.write(fieldType="radio",stForm="#o#",fieldName="resourcetype",optionData="resourceType")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="resourcename")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="resourceauthor")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="resourceURL")#

	<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="resourceid" value="#o.resourceid#">
	<input type="hidden" name="type" value="resource">
	<input type="hidden" name="action" value="configure">
	</div>
</form>
</cfoutput>