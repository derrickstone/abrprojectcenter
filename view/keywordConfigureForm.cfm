<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
<form action="#cgi.script_name#" method="post">
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="keywordname")#

	<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="keywordid" value="#o.keywordid#">
	<input type="hidden" name="type" value="keyword">
	<input type="hidden" name="action" value="configure">
	</div>
</form>
</cfoutput>