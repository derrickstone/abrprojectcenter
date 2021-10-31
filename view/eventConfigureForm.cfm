<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
<form action="#cgi.script_name#" method="post">
	
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="eventname")#
	#oWriter.write(fieldType="datefield",stForm="#o#",fieldName="eventstarttime")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="eventduration",default="45")#
	#oWriter.write(fieldType="selector",stForm="#o#",fieldName="eventhost",optiondata="usr")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="eventURL")#
	#oWriter.write(fieldType="radio",stForm="#o#",fieldName="eventstatus",optionData="eventstatus")#

	<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="eventid" value="#o.eventid#">
	<input type="hidden" name="type" value="event">
	<input type="hidden" name="action" value="configure">
	</div>
</form>
</cfoutput>