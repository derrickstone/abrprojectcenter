<cfcomponent extends="object">
<cfset this.type = "review">
<cffunction name="drawReviews">
<cfargument name="stReview">
<cfargument name="usr">
<cfargument name="bDrawReadonly">

<cfset var sReturn = "">

<cfif arguments.stReview.reviewid eq "">
	<cfset arguments.stReview.reviewid = -1>
</cfif>

<cfsavecontent variable="sReturn"><cfoutput>
<cfinclude template="/#application.viewpath#/reviewItemForm.cfm">
</cfoutput>
</cfsavecontent>

<cfreturn sReturn>
</cffunction>
<cffunction name="getApprovals">
	<cfargument name="responsedata">
	<cfargument name="approvaldata">

	<cfset var qget = "">

	<cfquery name="qget" >
	select review.*, usr.usrname, usr.firstname, usr.lastname, usr.email, responsetype.responsetypename from review inner join usr on usr.usrid=review.usr inner join responsetype on responsetype.responsetypeid=review.responsetype
		where review.responsedata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedata#">
		and review.approvaldata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvaldata#">
	</cfquery>
	
	<cfreturn qget>
</cffunction>
<cffunction name="getApprovalsAsArray">
	<cfargument name="qData">
	
	<cfset var aReturn = querytoarrayofstructs(arguments.qdata)>

	<cfreturn aReturn>
</cffunction>
<cffunction name="getdata">
	<cfargument name="id">

	<cfset var qget = "">

	<cfquery name="qget" >
	select review.*, usr.usrname from review 
	inner join usr on usr.usrid = review.usr
	where reviewid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>

	<cfreturn qget>
</cffunction>
<cffunction name="getReviews">
	<cfargument name="responsedata">
	<cfargument name="approvalset">

	<cfset var qget = "">

	<cfquery name="qget" >
	select * from review where 
		responsedata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedata#">
		and approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvalset#">
	</cfquery>

	<cfreturn qget>
</cffunction>
<cffunction name="handleeditform">
	<cfargument name="formdata">
	<cfargument name="returnnewid">

	<cfset var qcheck = "">
	<cfset var qupdate = "">
	<cfset var sMessage = "">

<!--- because we allow people to approve over email, we should ensure we aren't recording a duplicate approval
--->

<cfif structkeyexists(arguments.formdata,"approvalset") eq "no">
	<cfinvoke component="#application.modelpath#.approvaldata" method="getapprovalsetid" approvaldataid="#arguments.formdata.approvaldata#" returnvariable="arguments.formdata.approvalset"></cfinvoke>
</cfif>

<!--- save the approval 
approvals come in via email, and we'd like to prevent duplicates --->

<cfquery name="qcheck" >
select * from review where 
	usr = #arguments.formdata.usr# and 
	approvalset = #arguments.formdata.approvalset# and 
	approvaldata = #arguments.formdata.approvaldata# and
	responsedata = #arguments.formdata.responsedata# 
</cfquery>
<cfif qcheck.recordcount > <!--- update ---> 
	<cfquery name="qupdate" >
	update review set 
		datelastupdated = now(),
		responsetype = #arguments.formdata.responsetype#,
		approvalcomment = '#arguments.formdata.approvalcomment#'
		where
		reviewid = #qcheck.reviewid#
	</cfquery>	
	<cfif arguments.returnnewid eq true>
		<cfset sMessage = qcheck.reviewid>
	<cfelse>
		<cfset sMessage = "Updating record.">
	</cfif>
<cfelse> <!--- add --->

	<cfinvoke component="#application.modelpath#.object" method="handleEditForm" formdata="#arguments.formdata#" returnvariable="sMessage" returnnewid="#arguments.returnnewid#" type="review"></cfinvoke>
	
</cfif>

<!--- get the responsesetid for processing notices --->
<cfinvoke component="#application.modelpath#.responsedata" method="getresponsesetid" responsedataid="#arguments.formdata.responsedata#" returnvariable="responsesetid"></cfinvoke>

<!--- check to see if the approval is satisfied and move the workflow forward --->
<cfif arguments.formdata.responsetype eq 1> <!--- approved --->
	<!--- check to see if this satisfies the approval --->
	<cfinvoke component="#application.modelpath#.responsedata" method="getformid" responsedataid="#arguments.formdata.responsedata#" returnvariable="formid"></cfinvoke>
	
	<cfinvoke component="#application.modelpath#.responseset" method="setcurrentownerandnotify" responsesetid="#responsesetid#" formid="#formid#"></cfinvoke>
<cfelseif arguments.formdata.responsetype eq 2>
	<!--- returned! reset this request to the creator and to inactive sattus --->
	<cfinvoke component="#application.modelpath#.responseset" method="makeinactive" responsesetid="#responsesetid#" ></cfinvoke>
	<cfinvoke component="#application.modelpath#.responsedata" method="getformid" responsedataid="#arguments.formdata.responsedata#" returnvariable="formid"></cfinvoke>
	<cfinvoke component="#application.modelpath#.responseset" method="setcurrentownerandnotify" responsesetid="#responsesetid#" formid="#formid#"></cfinvoke>
</cfif>

<cfreturn sMessage>

	</cffunction>

</cfcomponent>