
<div class="posts"><cfoutput>
	<cfif arguments.id eq -1 and structkeyexists(url,"create") eq false >
			<a href="#cgi.script_name#?create=true">[ Create new -&gt; ]</a>

	</cfif>
	<cfif arguments.id neq -1 OR ( arguments.id eq -1 AND structkeyexists(url,"create") and url.create eq "true")>
	<form action="#cgi.SCRIPT_NAME#" method="post">
		
	<input type="hidden" name="type" value="#arguments.type#">
	<input type="hidden" name="#arguments.type#id" value="#arguments.id#">
	<input type="hidden" name="action" value="edit">
	<input type="text" name="#arguments.type#name" value="#arguments.name#">
	<input type="submit" name="submit" value="Save"><input type="submit" name="cancel" value="Cancel">
	</cfif>
</form></cfoutput></div>