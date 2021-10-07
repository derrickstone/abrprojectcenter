<cfcomponent extends="object">

<cfset this.type="approvalSet">
<cffunction name="delete" hint="extends delete to also remove related approvals">
		<cfargument name="type" type="String">
		<cfargument name="id" type="numeric">

		<cfset var qDel1 = "">
		<cfset var qDelete = "">
		<cfset var qget = "">
		<cfset var qdel2 = "">

		<!--- check access level --->
		<cfif session.usr.accesslevel eq 1>
			<!--- STUB: maybe a good place for cftransaction? --->
			<cfquery name="qget" datasource="#application.dsn#">
			select approvalid from approval where approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfquery name="qdel2" datasource="#application.dsn#">
			delete from approval where approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<cfquery name="qDel1" datasource="#application.dsn#">
			delete from approvaldata where approval in <cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qget.approvalid)#" list="yes">
			</cfquery>

			<cfquery name="qDelete" datasource="#application.dsn#">
			delete from approvalset where approvalsetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			
			<cfreturn "Deleted.">
			
		<cfelse>
			<Cfreturn "Insufficient privileges">
		</cfif>
		
		</cffunction>

<cffunction name="drawReviewField" output="true">
	<cfargument name="fielddata">
	<cfargument name="responsedataid">
	<cfargument name="responsesetstatus">
	<cfargument name="printformat" default="false">
	
	<cfset var sReturn ="">
	<cfset var lReviewUsrs = "">
	<cfset var lAdHocUsrs = "">
	<cfset var i = 1>

	<cfset sReturn = sReturn & "<div><strong>#arguments.fielddata.stApprovalSet.approvalsetname#</strong></div>">

	<cfif arraylen(arguments.fielddata.stapprovalset.aapprovaldata) gt 0>
		<cfloop from="1" to="#arraylen(arguments.fielddata.stapprovalset.aapprovaldata)#" index="i">
			<cfinvoke component="#application.modelpath#.approvaldata" method="drawApprovalData" returnvariable="sRecord" recorddata="#arguments.fielddata.stapprovalset.aapprovaldata[i]#" reviewdata="#arguments.fielddata.stReview#" printformat="#arguments.printformat#" responsedataid="#arguments.responsedataid#" responsesetstatus="#arguments.responsesetstatus#"></cfinvoke>
			<Cfset sReturn = sReturn & sRecord>
		</cfloop>

	<cfelse>
		<cfset sReturn = sReturn & "No review steps have been defined.">
	</cfif>
	
	<!---
	<cfset sReturn = sReturn & "<div>#positivereview# approvals of #possiblereview#">
	--->
	<cfif arguments.fielddata.satisfied eq true>
		<cfset sReturn = sReturn & " (Satisfied)">
	<cfelse>
		<cfset sReturn = sReturn & " (Not Satisfied)">
	</cfif>	
	<!---
	<cfif arguments.fielddata.approvaltype eq 2> <!--- any --->			
		<cfif arguments.fielddata.satisfied eq true >
			<cfset sReturn = sReturn & " (Satisfied)">
		<cfelse>
			<cfset sReturn = sReturn & " (Not Satisfied)">
		</cfif>
	<cfelseif arguments.fielddata.approvaltype eq 1> <!--- all ---><cfoutput>showing as <cfdump var="#arguments.stApprovalData#"> #arguments.stApprovalData.satisfied#</cfoutput>
		<cfif possiblereview gt 0 and positivereview eq possiblereview>
			<cfset sReturn = sReturn & " (Satisfed)">
		<cfelse>
			<cfset sReturn = sReturn & " (Not Satisfied)">
		</cfif>
	</cfif>
--->
<!---	<cfset sReturn = sReturn & "</div>"> --->

	

	<cfreturn sReturn>
</cffunction>

<!--- STUB: build in some caching --->
<cffunction name="getApprovers" output="false">
	<cfargument name="formfield" >
	<cfargument name="responsesetid">
	<!--- <cfargument name="responsedata"> --->
	<cfargument name="approvalsetid">

	<cfset var qget = "">
	<cfset var lApprovers = "">

	<cfquery name="qget" datasource="#application.dsn#">
	select * from formfield inner join approvalset on approvalset.approvalsetid = formfield.approvalset
	inner join approvaldata on approvaldata.approvalset = approvalset.approvalsetid
	 where approvalset.approvalsetid = #arguments.approvalsetid# and formfield.fieldtype = 7 
	 and formfield.formfieldid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfield#">
	</cfquery>

	<cfloop query="qget">

	<cfif isnumeric(qget.usr) and qget.usr neq 0>
		<cfset lApprovers=listappend(lApprovers,qget.usr)>
	</cfif>
	<cfif isnumeric(qget.approvalgroup) and qget.approvalgroup neq 0>
		<cfinvoke component="#application.modelpath#.approvalgroup" method="getmembers" approvalgroup="#qget.approvalgroup#" returnvariable="qApprovalGroup"></cfinvoke>
		<cfset lApprovers=listappend(lApprovers,valuelist(qapprovalgroup.usr))>
	</cfif>
	
	<cfif isnumeric(qget.optiondata) and qget.optiondata neq 0 and isnumeric(arguments.responsesetid) and arguments.responsesetid neq 0>
		<!--- get responseset and option data from optiondataid --->
		<!---
		<cfinvoke component="#application.modelpath#.responsedata" method="getusrselectedoption" returnvariable="selectedoption" responsedata = "#url.responsedataid#" optionset="#qget.optiondata#"></cfinvoke>
		<cfinvoke component="#application.modelpath#.optiondata" method="getmembers" optiondata="#selectedoption#" returnvariable="qOptionData"></cfinvoke>
	--->
		<cfinvoke component="#application.modelpath#.responseset" method="getalluserselectedoptionapprovers" formid="#arguments.formid#" responseset="#arguments.responsesetid#" returnvariable="loapprovers"></cfinvoke>
		<cfset lApprovers=listappend(lApprovers,loapprovers)>

	</cfif>
	<cfif isnumeric(qget.adhocnumber) and qget.adhocnumber gt 0>
		<cfinvoke component="#application.modelpath#.adhoc" method="getmembers" returnvariable="qAdHocMembers" responsedata="#arguments.responsedata#" approvalset="#arguments.approvalsetid#" ></cfinvoke>
		<cfloop query="qadhocmembers">
			<cfif qadhocmembers.usr neq 0>
			<cfset lApprovers = listappend(lApprovers,qadhocmembers.usr)>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isnumeric(qget.adhocauthorizer) and qget.adhocauthorizer gt 0>
		
		<cfset lApprovers = listappend(lApprovers,qget.adhocauthorizer)>
	</cfif>
	</cfloop> 
	<cfreturn lapprovers>
</cffunction>
<cffunction name="getData">
	<cfargument name="id" default="">

	<cfset qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
		select approvalset.*, approvalset.approvalsetid as id, approvalset.approvalsetname as name,
		 approvaltype.approvaltypename from approvalset inner join 
		approvaltype on approvaltype.approvaltypeid = approvalset.approvaltype
		<cfif len(arguments.id)>
		where approvalset.approvalsetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfif>
		order by approvalset.approvalsetname
	</cfquery>
	<cfreturn qget>
</cffunction>
<cffunction name="getOptionData">
	<cfargument name="optionsetid">
	<cfset var qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
	select optiondataid, optiondataid as id, optiondataname, optiondataname as name from optiondata where optionset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.optionsetid#">
		order by sortkey
	</cfquery>
	<cfreturn qget>
</cffunction>
<cffunction name="getRecipient">
	<cfargument name="approvalsetid">

	<cfset var qgetusr = "">
	<cfset var qgetApprovalGroup = "">
	<cfset var lreturn = "">

	<cfquery name="qgetusr" datasource="#application.dsn#">
	select approvaldataid, usr, approvalgroup, adhocnumber from approvaldata where approvalsetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvalsetid#">
	</cfquery>
	<cfset lreturn = valuelist(qget.usr)>
	<cfloop query="qGetUsr">
		<cfif isnumeric(qGetUsr.approvalgroup)>
			<cfquery name="qgetApprovalGroup" datasource="#application.dsn#">
			select usr from keyusrapprovalgroup where approvalgropu = <cfqueryparam cfsqltype="cf_sql_integer" value="#qgetusr.approvalgroup#">
			</cfquery>
			<cfloop query="qGetApprovalGroup">
				<cfif isnumeric(qGetApprovalGroup.usr)>
					<cfset lReturn = listappend(lReturn,qGetApprovalGroup.usr)>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>

	<cfif isnumeric(qgetusr.adhocnumber) and qgetusr.adhocnumber neq 0>
		<cfquery name="qgetAdHoc" datasource="#application.dsn#">
		select usr from adhoc where approvaldata in <cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qgetusr.approvaldata)#" list="true">
		</cfquery>
		<cfloop query="qGetAdHoc">
			<cfset lreturn = listappend(lreturn,qgetadhoc.usr)>
		</cfloop>
	</cfif>


	<cfreturn lReturn>
</cffunction>

<cffunction name="getSets">
	<cfargument name="usr" >

	<cfset var qget = "">

	<!--- stub: we should add somethin for the organization here 
	<cfquery name="qget" datasource="#application.dsn#">
	select optionsetid, optionsetname from set where 
	creator = #arguments.usr#
	</cfquery> --->
	<cfinvoke component="#application.modelpath#.object" method="getData" type="optionset" returnvariable="qget"></cfinvoke>

	<cfreturn qget>
</cffunction>
<cffunction name="update">
	<cfargument name="approvalsetid">
	<cfargument name="satisifed" default="">

	<cfset var qUpdate = "">

	<cfquery name="qUpdate" datasource="#application.dsn#">
	update approvalset set
		<cfif isnumeric(arguments.satisfied)>
		satisfied = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.satisfied#">
		</cfif>
		where approvalsetid =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.satisfied#">
	</cfquery>
</cffunction>

</cfcomponent>