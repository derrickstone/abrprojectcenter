<div class="posts"><cfoutput><form action="#cgi.SCRIPT_NAME#" method="post">
		<cfif arguments.id eq -1>
			Create new -&gt;
		</cfif>
	<input type="hidden" name="type" value="#arguments.type#">
	<input type="hidden" name="#arguments.type#id" value="#arguments.id#">
	<input type="hidden" name="action" value="edit">
	<input type="text" name="#arguments.type#name" value="#arguments.name#">
	<input type="submit" name="submit" value="Save"><input type="submit" name="cancel" value="Cancel">
</form></cfoutput></div>