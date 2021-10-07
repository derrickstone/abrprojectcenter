<cfcomponent extends="object">
<cfset this.type="responseData">
<!---
<cffunction name="checkforapprovalchange">
		<cfargument name="responsedataid">
		<!--- this function checks to see if there has been a change in the satisfied property and, if so, makes the necessary notification --->
		<cfset var qCheckStatus = "">
		<cfset var previousvalue = 0>
		<cfset var currentvalue = 0>

		<!--- get the current satisfied value --->
		<cfquery name="qcheckstatus" >
			select responsedata.*, approvalset.approvalsetid, approvalset.approvaltype, form.formid, formfield.sortkey from responsedata
			inner join formfield on formfield.formfieldid = responsedata.formfield
			inner join approvalset on approvalset.approvalsetid = formfield.approvalset
			inner join form on form.formid = formfield.form
			where responsedata.responsedataid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">
		</cfquery>
		<cfset previousvalue = qcheckstatus.satisfied>

		<!--- calculate current value --->

		<!--- check the usr --->
		<cfif isnumeric(responsedata.usr) and responsedata.usr neq 0>

			<cfquery name="qcheckapproval">
			select responsetype from approval where usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#qcheckstatus.usr#">
			and approvaldata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">
			</cfquery>
			<cfif qcheckapproval.responsetype eq 1>
				<cfset currentvalue = 1>
			</cfif>
		</cfif>
		<!--- check the group --->
		<cfif isnumeric(responsedata.approvalgroup) and responsedata.approvalgroup neq 0>
			<cfquery name="qGetGroupMembers" >
			select usr from keyusrapprovalgroup where approvalgroup = <cfqueryparam cfsqltype="cf_sql_integer" value="#responsedata.approvalgroup#">
			</cfquery>
			<cfif qGetGroupMembers.recordcount>
				<cfset currentvalue = 0>
				<cfif qcheckstatus.approvaltype eq 1> <!--- all --->
					<cfquery name="qCheckGroup" >
					select responsetype from approval where usr in <cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qGetGroupMembers.usr)#" list="true">
					</cfquery>
					<cfif qCheckGroup.recordcount lt qGetGroupMembers.recordcount>
						<cfset currentvalue = 0>
					<cfelse>
						<cfloop query="qCheckGroup">
							<cfif qCheckGroup.responsetype neq 1>
								<cfset currentvalue = 0>
								<cfbreak>
							<cfelse>
								<cfset currentvalue = 1>
							</cfif>
						</cfloop>
					</cfif>
					
				<cfelse>
					<!--- anyone in the group can approve --->
					<!--- STUB: this ignores a return --->
					<cfquery name="qCheckGroup" >
					select responsetype from approval where usr in <cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qGetGroupMembers.usr)#" list="true"> and approvaltype = 1
					</cfquery>
					<cfif qcheckgroup.recordcount gt 1>
						<cfset currentvalue = 1>
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<!--- check adhoc approvals --->
		
		<cfif isnumeric (qGetAdHocNumber.adhocnumber)>
			<cfquery name="qCheckAdHoc" >
				select * from adhoc where approvaltype = 1 and responsedata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">
				</cfquery>
			<cfif qCheckStatus.approvaltype eq 1> <!--- all --->
				<cfquery name="qGetAdHocNumber" >
				select adhocnumber from approvaldata where approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#qcheckStatus.approvalsetid#">
				</cfquery>

				<cfif qCheckAdHoc.recordcount eq qGetAdHocNumber.adhocnumber>
					<cfset currentvalue = 1>
				</cfif>
			<cfelse>
				
				<cfif qCheckAdHoc.recordcount gt 0>
					<cfset currentvalue = 1>
				</cfif>

			</cfif>
		</cfif>

		<cfif previousvalue neq qchecknewvalue.value>
			<!--- handle notifications --->
			<!--- we want to notify the next actor --->
			<cfquery name="qGetNext" >
			select * from formfield where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#qcheckStatus.formid#">
				and sortkey > <cfqueryparam cfsqltype="cf_sql_integer" value="#qcheckStatus.sortkey#">
				order by sortkey asc
			</cfquery>
			<cfif qGetNext.recordcount>
				<cfif qGetNext.approvalset neq "">
					<!--- notify next approver --->
					<cfinvoke component="#application.modelpath#.approvalset" approvalsetid = "#qgetnext.approvalset#" method="getRecipient" returnvariable="recipient"></cfinvoke>
					
				<cfelse>
					<!--- notify the original submitter --->
					<cfset recipient = qcheckStatus.creator>
				</cfif>
				<cfinvoke component="#application.modelpath#.notice" method="sendNotice" usr="#recipient#"></cfinvoke>
			</cfif>
			<cfreturn true>
		</cfif>
		<cfreturn false>
</cffunction>
--->
<cffunction name="getApprovalsForApprovalSet">
	<cfargument name="approvalsetid">

	<Cfset var qget = "">

	<Cfquery name="qget" >
	select * from approval where approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvalsetid#">
</Cfquery>

	<Cfreturn qget>
</cffunction>
<cffunction name="getformfieldid">
	<cfargument name="responsedataid">
	<cfset var qget = "">

	<cfquery name="qget" >
		select formfield from responsedata 
		where responsedata.responsedataid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">
	</cfquery>

	<cfreturn qget.formfield>
</cffunction>
<cffunction name="getformid">
	<cfargument name="responsedataid">
	<cfset var qget = "">

	<cfquery name="qget" >
		select form from responseset inner join responsedata on responsedata.responseset = responseset.responsesetid
		where responsedata.responsedataid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">
	</cfquery>


	<cfreturn qget.form>
</cffunction>
<cffunction name="getpreviousselectedoption">
	<cfargument name="optionset">
	<cfargument name="responseset">
	<cfargument name="responsedata">

	<Cfset var qget = "">

	<cfif arguments.optionset eq "" or arguments.responseset eq "" or arguments.responsedata eq "">
		<Cfreturn "">
	</Cfif>

	<cfquery name="qget" >
	select stringresponse from responsedata
	inner join formfield on formfield.formfieldid = responsedata.formfield
	 where responseset = #arguments.responseset# and responsedataid < #arguments.responsedata# order by responsedata desc
	</cfquery>

	<cfreturn qget.stringresponse>

</cffunction>

<cffunction name="getresponsesetid">
	<cfargument name="responsedataid">

	<Cfset var qget ="">
	<cfquery name="qget" >
	select responseset from responsedata where responsedataid =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">
	</cfquery>

	<cfreturn qget.responseset>
	</cffunction>
<cffunction name="getresponseasstruct">
	<cfargument name="responseset">
	<cfargument name="formfield">

	<!--- STUB: this will need optimizing --->
	<cfset var qget = "">
	<cfset var stTemp = structnew()>
	
	<!--- STUB: add indexes --->
	<cfquery name="qGet" >
	select * from responsedata where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfield#"> and responseset=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responseset#">
	</cfquery>
	
	<cfloop list="#qget.columnlist#" index="c">
		<cfset stTemp[c]= evaluate("qget.#c#")>
	</cfloop>

	<cfreturn stTemp>
</cffunction>

<cffunction name="getusrselectedoption">
	<cfargument name="optionset">
	<!---<cfargument name="responseset">--->
	<cfargument name="responsedata">

	<Cfset var qget = "">
	<cfset var qResponseSet = "">
<!---
	<cfif arguments.optionset eq "" or arguments.responseset eq "" or arguments.responsedata eq "">
		<Cfreturn "">
	</Cfif> --->
	<cfquery name="qResponseSet" >
	select responseset from responsedata where responsedataid = #arguments.responsedata#
	</cfquery>


	<cfquery name="qget" >
	select stringresponse from responsedata
	inner join formfield on formfield.formfieldid = responsedata.formfield
	 where 
	 responseset = #qResponseSet.responseset# and

	 responsedataid < #arguments.responsedata# and optionset=#arguments.optionset#
	
	order by responsedataid desc
	</cfquery>
	<cfreturn qget.stringresponse>

</cffunction>
</cfcomponent>
