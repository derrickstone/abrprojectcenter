<cfcomponent extends="object">
<cffunction name="getItemsToReview">
	<cfargument name="usr">

	<cfset var qget = "">
	<cfset var qApprovalGroups = "">
	<cfset var qAdHoc = "">

	<cfquery name="qApprovalGroup" datasource="#application.dsn#">
	select approvalgroup from keyusrapprovalgroup where 
	usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usr#">
	</cfquery>

	<cfquery name="qAdHoc" datasource="#application.dsn#">
	select responseset from adhoc where usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usr#">
	</cfquery>

	<!--- join form, formfield, approvalset, approvaldata, responseset --->
	<cfquery name="qget" datasource="#application.dsn#">
	select form.formid, responseset.form,
	responseset.responsesetid, form.formname, 
	responseset.datelastupdated, usr.usrname,
	responseset.datecreated,
	responsesetstatus.responsesetstatusname

	from form inner join
	responseset on responseset.form = form.formid
	inner join formfield on formfield.form = form.formid
	inner join approvalset on approvalset.approvalsetid = formfield.approvalset
	inner join approvaldata on approvaldata.approvalset = approvalset.approvalsetid
	inner join usr on usr.usrid = responseset.usr
	inner join responsesetstatus on responsesetstatus.responsesetstatusid = responseset.responsesetstatus
	where ( responseset.responsesetstatus = 2 or responseset.responsesetstatus = 3 )
	and ( approvaldata.usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usr#"> )
		<!---
		<cfif qApprovalGroup.recordcount>
		or approvaldata.approvalgroup in <cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qApprovalGroup.approvalgroup)#" list="true">
		</cfif>
		<cfif qAdHoc.recordcount>
		or responseset.responsesetid in <cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qAdHoc.responseset)#" list="true">
		</cfif>
		) --->
	</cfquery>

	<!--- still need option data and ad hoc --->
	<cfreturn qget>
</cffunction>
</cfcomponent>