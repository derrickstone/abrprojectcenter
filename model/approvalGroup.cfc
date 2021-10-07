<cfcomponent extends="object">
<cfset this.type="approvalGroup">
<cffunction name="getMembers">
	<cfargument name="approvalgroup">

	<cfset var qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
	select keyusrapprovalgroup.usr, usr.usrid, usr.firstname, usr.lastname, usr.email
	from keyusrapprovalgroup inner join usr on usr.usrid=keyusrapprovalgroup.usr
	where keyusrapprovalgroup.approvalgroup = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.approvalgroup)#">
	</cfquery>
	<cfreturn qget>
</cffunction>

</cfcomponent>