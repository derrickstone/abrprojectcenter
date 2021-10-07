<cfset thispage = listlast(cgi.SCRIPT_NAME,"/")>

<ul class="links">

	<li <cfif thispage eq "index.cfm">class="active"</cfif>><a href="index.cfm">Home</a></li>

	<li <cfif thispage eq "resources.cfm">class="active"</cfif>><a href="resources.cfm">Resources</a></li>
	<li <cfif thispage eq "projects.cfm">class="active"</cfif>><a href="projects.cfm">Projects</a></li>
	<li <cfif thispage eq "events.cfm">class="active"</cfif>><a href="events.cfm">Events</a></li>
	<li <cfif thispage eq "people.cfm">class="active"</cfif>><a href="people.cfm">People</a></li>
	
</ul>