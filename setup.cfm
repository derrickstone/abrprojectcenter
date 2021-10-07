<ul>
<li ><a href="formgroups.cfm">Grouping categories for forms</a></li>
<li ><a href="optionSets.cfm">Configure options for single or multiple select</a></li>
<li ><a href="users.cfm">Users</a></li>
<li ><a href="approvalgroups.cfm">Groups of approvers</a></li>
<li ><a href="approvalSets.cfm">Configure approval steps</a></li>
</ul>

<cfif session.usr.usrid eq 2 and 0>
<a href="setup.cfm?resetalluserdata=true" onclick="return confirm'Are you sure?');">[ Reset all user data ] </a>

<cfif structkeyexists(url,"resetalluserdata") and url.resetalluserdata eq true>

	<cfset luserdatatables ="adhoc,approval,approvaldata,approvalgroup,approvalresponse,approvalset,fileattachment,form,formfield,formgroup,forminstance,keyformgroupform,keyformorganization,keyoptiondata,keyusrapprovalgroup,keyusroptiondata,keyusrorganization,noticequeue,optiondata,optionset,organization,responsedata,responseset,responsesethistory,usrtoken">
	<cfoutput>
	<cfloop list="#luserdatatables#" index="t">
		clearing table #t#

	<Cfquery name="qd1" datasource="#application.dsn#">
	delete from #t#
	</Cfquery>
	done.<br>
	</cfloop>
	</cfoutput>
	Complete.
</cfif>

</cfif>