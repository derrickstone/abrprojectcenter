<cfset thispage = listlast(cgi.SCRIPT_NAME,"/")>

<ul class="links">

	<li <cfif thispage eq "index.cfm">class="active"</cfif>><a href="index.cfm">Home</a></li>

	<li <cfif thispage eq "resource.cfm">class="active"</cfif>><a href="resource.cfm">Resources</a></li>
	<li <cfif thispage eq "project.cfm">class="active"</cfif>><a href="project.cfm">Projects</a></li>
	<li <cfif thispage eq "event.cfm">class="active"</cfif>><a href="event.cfm">Events</a></li>
	<li <cfif thispage eq "people.cfm">class="active"</cfif>><a href="people.cfm">People</a></li>
	
</ul>