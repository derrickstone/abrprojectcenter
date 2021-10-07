<cfcomponent extends="object">
<cfset this.type="approvaldata">
<cffunction name="drawApprovalForm" output="false">
	<cfargument name="label">
	<cfargument name="formfieldid">

	<!--- STUB: this will need optimizing --->
	<cfset var sReturn = "">
	<cfset var qApprovalSets = "">
	
	<cfset var qApprovals = "">
	<cfset var qApprovalData = "">

	<cfquery name="qApprovalSets" >
	select * from approvalset where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfieldid#">
	</cfquery>
	<cfquery name="qApprovals" >
	select * from approvaldata 
	left outer join approval on approval.approvaldata = approvaldata.approvaldataid
	where approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#qApprovalSets.approvalsetid#">
	</cfquery>
	
	<cfsavecontent variable="sReturn"><cfoutput>

	</cfoutput></cfsavecontent>

	<cfreturn sReturn>
</cffunction>

<cffunction name="drawApprovalData" output="false">
	<cfargument name="recorddata">
	<cfargument name="reviewdata">
	<cfargument name="responsedataid">
	<cfargument name="responsesetstatus">
	<cfargument name="printformat" default="false">

	<cfset var sReturn = "">
	<cfset var lapprovers = "">

	<!--- build a list of users who can approve for this record, including specified usr, an approval group or an option group --->
	<cfif isnumeric(arguments.recorddata.usr)>
		<cfset lapprovers = listappend(lapprovers,arguments.recorddata.usr)>
	</cfif>
	<cfif structkeyexists(arguments.recorddata,"aapprovalgroup") and isarray(arguments.recorddata.aApprovalGroup)>
		<cfloop from="1" to="#arraylen(arguments.recorddata.aApprovalGroup)#" index="x">
			<cfif isnumeric(arguments.recorddata.aApprovalGroup[x].usr) and listfind(lapprovers,x) eq 0>
				<cfset lapprovers=listappend(lapprovers,arguments.recorddata.aApprovalGroup[x].usr)>
			</cfif>
		</cfloop>
	</cfif>
	<cfif structkeyexists(arguments.recorddata,"aOptionGroup") and isarray(arguments.recorddata.aOptionGroup)>
		<cfloop from="1" to="#arraylen(arguments.recorddata.aOptionGroup)#" index="x">
			<cfif isnumeric(arguments.recorddata.aOptionGroup[x].usr) and listfind(lapprovers,x) eq 0>
				<cfset lapprovers=listappend(lapprovers,arguments.recorddata.aOptionGroup[x].usr)>
			</cfif>
		</cfloop>
	</cfif>
	<cfloop list="#lApprovers#" index="u">
		<!--- STUB: this is extremely slow design - be sure this is cached!! --->		
		<cfinvoke component="#application.modelpath#.usr" method="getUsr" usrid="#u#" returnvariable="udata"></cfinvoke>
		<cfset sReturn = sReturn & "<div>#namestring(udata.lastname,udata.firstname)# &lt;#udata.email#&gt;">

		<cfset sReturn = sReturn & " <span class='approvaltype'>">
		<cfif structkeyexists(arguments.reviewdata,u)>
			<cfif arguments.reviewdata[u].responsetype eq 1>
				<cfset sReturn = sReturn & "approved">				
			<cfelse>
				<cfset sReturn = sReturn & "returned">
			</cfif>
		<cfelse>
			<cfset sReturn = sReturn & "not reviewed">
		</cfif>
		<cfset sReturn = sReturn & " </span>">
		<cfif structkeyexists(arguments.reviewdata,u)>
			<cfset sReturn = sReturn & "<div class='comment'>" & arguments.reviewdata[u].approvalcomment & "</div>">
		</cfif>
		<cfset sReturn = sReturn & " </div>">
		<cfif arguments.printformat eq false>
			<!---<cfoutput>[#arguments.responsesetstatus#. #session.usr.usrid# .#arguments.stApprovalData.usr#]</cfoutput>--->
			<cfif arguments.responsesetstatus gt 1 and ( u eq session.usr.usrid  OR session.usr.accesslevel lte 2)>
				<cfset sReturn = sReturn & '<a href="review.cfm?approvaldataid=#arguments.recorddata.approvaldataid#&responsedataid=#arguments.responsedataid#" class="reviewbutton">[ Review ]</a>'>
			</cfif>
		</cfif>	
	</cfloop>


	<!--- ad hoc approvals must be drawn as form fields --->
	<cfif structkeyexists(arguments.recorddata,"aAdHocGroup") and isarray(arguments.recorddata.aAdHocGroup) and arraylen(arguments.recorddata.aAdHocGroup) gt 0>

		<cfset v = 1>
		<!---<cfset sReturn = sReturn & '<span class="dim">If an approver already exists in the system, you will be unable to update the name or department details.</span>'>--->
		<cfloop from="1" to="#arraylen(arguments.recorddata.aAdHocGroup)#" index="l">
			<cfif isnumeric(arguments.recorddata.adhocminimum) and arguments.recorddata.adhocminimum gt l>
				<cfset required=true>
			<cfelse>
				<cfset required = false>
			</cfif>
			<cfinvoke component="#application.modelpath#.adhoc" method="drawAdHocControl" reviewdata="#arguments.reviewdata#" recorddata="#arguments.recorddata.aAdHocGroup[l]#" returnvariable="sAdHoc" responsedataid="#arguments.responsedataid#" required="#required#" sortkey="#l#" responsesetstatus="#arguments.responsesetstatus#"></cfinvoke>
			<Cfset sReturn = sReturn & sAdHoc>			
			
		</cfloop>
	</cfif>

	<cfif structkeyexists(arguments.recorddata,"adhocauthorizer") and isnumeric(arguments.recorddata.adhocauthorizer)>

		<cfinvoke component="#application.modelpath#.usr" method="getUsr" usrid="#arguments.recorddata.adhocauthorizer#" returnvariable="udata"></cfinvoke>
		<cfset sReturn = sReturn & "<div>Ad Hoc authorizer: #namestring(udata.lastname,udata.firstname)# &lt;#udata.email#&gt;">

		<cfset sReturn = sReturn & " <span class='approvaltype'>">
		<cfif structkeyexists(arguments.reviewdata,arguments.recorddata.adhocauthorizer)>
			<cfif arguments.reviewdata[arguments.recorddata.adhocauthorizer].responsetype eq 1>
				<cfset sReturn = sReturn & "approved">				
			<cfelse>
				<cfset sReturn = sReturn & "returned">
			</cfif>
		<cfelse>
			<cfset sReturn = sReturn & "not reviewed">
		</cfif>
		<cfset sReturn = sReturn & " </span>">
		<cfif structkeyexists(arguments.reviewdata,arguments.recorddata.adhocauthorizer)>
			<cfset sReturn = sReturn & "<div class='comment'>" & arguments.reviewdata[arguments.recorddata.adhocauthorizer].approvalcomment & "</div>">
		</cfif>
		<cfset sReturn = sReturn & " </div>">
		<cfif arguments.printformat eq false>
			<!---<cfoutput>[#arguments.responsesetstatus#. #session.usr.usrid# .#arguments.stApprovalData.usr#]</cfoutput>--->
			<cfif arguments.responsesetstatus gt 1 and ( udata.usrid eq session.usr.usrid  OR session.usr.accesslevel lte 2)>
				<cfset sReturn = sReturn & '<a href="review.cfm?approvaldataid=#arguments.recorddata.approvaldataid#&responsedataid=#arguments.responsedataid#" class="reviewbutton">[ Review ]</a>'>
			</cfif>
		</cfif>	
	</cfif>


	<cfreturn sReturn>
</cffunction>

<!---
<cffunction name="drawApprovalData" output="true">
	<cfargument name="stApprovalData">
	<cfargument name="stReviews">
	<cfargument name="responsesetstatus" default="1">
	<cfargument name="responsedataid">
	<cfargument name="formfield">
	<cfargument name="printformat" default="false">
	<cfargument name="approvaltype">

	<cfset var sReturn ="">

	<cfset var lReviewUsrs = "">
	<cfset var lAdHocUsrs = "">


	<!--- set a default if responsedata has not been saved --->
	<cfif arguments.stApprovalData.responsedata eq "">
		<cfset arguments.stApprovalData.responsedata = 0>
	</cfif>
	<cfif arguments.responsedataid eq "">
		<cfset arguments.responsedataid = 0>
	</cfif>

	<!--- add all the possible usr ids --->
	<cfif isnumeric(arguments.stApprovalData.usr)>
		<cfset lReviewUsrs= listappend(lReviewUsrs,arguments.stApprovalData.usr)>
	</cfif>
	<!--- add the members of an approval group --->
	<cfif structkeyexists(arguments.stApprovalData,"aApprovalGroup") and isarray(arguments.stApprovalData.aApprovalGroup) and arraylen(arguments.stApprovalData.aApprovalGroup) gt 0>
		<cfloop from="1" to="#arraylen(arguments.stApprovalData.aApprovalGroup)#" index="l">
			<cfset lReviewUsrs= listappend(lReviewUsrs,arguments.stApprovalData.aApprovalGroup[l].usr)>
		</cfloop>
	</cfif>
	<!--- add the users who can review as part of a selected option group --->
	<!--- option data connection --->
	<cfif structkeyexists(arguments.stApprovalData,"aOptionData") and isarray(arguments.stApprovalData.aOptionData) and arraylen(arguments.stApprovalData.aOptionData) gt 0>
		<cfloop from="1" to="#arraylen(arguments.stApprovalData.aOptionData)#" index="l">
			<cfset lReviewUsrs= listappend(lReviewUsrs,arguments.stApprovalData.aOptionData[l].usr)>
		</cfloop>
	</cfif>
	
	<!--- all approvals are used for any of the users indicated as approvers for this step 
		For example, if a user is specified in an approval group AND as an approval usr, only
		one approval will count towards both approval opportunities. The tie is to the approvaldata record
		--->
	<!--- for convenient lookup, convert the array of approvals into a structure --->
	<!---
	I don't think this is necessary, now that we are using a struct to store reviews
	<cfset stApprovals = structnew()>
	<cfif isstruct(arguments.stReviews) and structcount(arguments.stReviews) gt 0>
		<cfloop from="1" to="#arraylen(arguments.aReviews)#" index="m">
			<!--- is ther a more clever way to use these keys? --->			
			<cfset stApprovals[arguments.aReviews[m].usr]=m>
		</cfloop>
	</cfif> --->
	<!--- should we control for duplicates? --->
	
	<cfset sReturn = sReturn & "<div><strong>#arguments.stApprovalData.approvaldataname#</strong></div>">
	<cfset possiblereview = 0>
	<cfset positivereview = 0>
	<!--- create a list of the usr ids in an approval group --->
	<cfset lapprovers="">
	<cfif isnumeric(arguments.stapprovaldata.usr)>
		<cfset lapprovers = listappend(lapprovers,arguments.stapprovaldata.usr)>
	</cfif>
	<cfif isarray(arguments.stapprovaldata.ApprovalGroup)>
		<cfloop from="1" to="#arraylen(arguments.stapprovaldata.ApprovalGroup)#" index="x">
			<cfif isnumeric(arguments.stapprovaldata.ApprovalGroup[x].usr) and listfind(lapprovers,x) eq 0>
				<cfset lapprovers=listappend(lapprovers,arguments.stapprovaldata.ApprovalGroup[x].usr)>
			</cfif>
		</cfloop>
	</cfif>

	<cfloop list="#lReviewUsrs#" index="u">
		<!--- STUB: this is extremely slow design --->
		<cfset possiblereview = possiblereview+1>
		<cfinvoke component="#application.modelpath#.usr" method="getUsr" usrid="#u#" returnvariable="udata"></cfinvoke>
		<cfset sReturn = sReturn & "<div>#namestring(udata.lastname,udata.firstname)# &lt;#udata.email#&gt;">

		<cfset sReturn = sReturn & " <span class='approvaltype'>">
		<cfif structkeyexists(arguments.stReviews,u)>
			<cfif arguments.stReviews[u].responsetype eq 1>
				<cfset sReturn = sReturn & "approved">
				<cfset positivereview =positivereview+1>
			<cfelse>
				<cfset sReturn = sReturn & "returned">
			</cfif>
		<cfelse>
			<cfset sReturn = sReturn & "not reviewed">
		</cfif>
		<cfset sReturn = sReturn & " </span>">
		<cfif structkeyexists(stReviews,u)>
			<cfset sReturn = sReturn & "<div class='commment'>" & arguments.stReviews[u].approvalcomment & "</div>">
		</cfif>
		<cfset sReturn = sReturn & " </div>">
		<cfif arguments.printformat eq false>
			<!---<cfoutput>[#arguments.responsesetstatus#. #session.usr.usrid# .#arguments.stApprovalData.usr#]</cfoutput>--->
			<cfif arguments.responsesetstatus gt 1 and ( u eq session.usr.usrid  OR session.usr.accesslevel lte 2)>
				<cfset sReturn = sReturn & '<a href="review.cfm?approvaldataid=#arguments.stApprovalData.approvaldataid#&responsedataid=#arguments.responsedataid#" class="reviewbutton">[ Review ]</a>'>
			</cfif>
		</cfif>	
	</cfloop>
	

	<!--- ad hoc approvals must be drawn as form fields --->
	<cfif structkeyexists(arguments.stApprovalData,"aAdHocGroup") and isarray(arguments.stApprovalData.aAdHocGroup) and arraylen(arguments.stApprovalData.aAdHocGroup) gt 0>

		<cfset v = 1>
		<!---<cfset sReturn = sReturn & '<span class="dim">If an approver already exists in the system, you will be unable to update the name or department details.</span>'>--->
		<cfloop from="1" to="#arraylen(arguments.stApprovalData.aAdHocGroup)#" index="l">
			
			<cfset au = arguments.stApprovalData.aAdHocGroup[l]>

			<!--- STUB: this is extremely slow design --->
			<!---<cfinvoke component="#application.modelpath#.usr" method="getUsr" usrid="#au.usr#" returnvariable="udata"></cfinvoke>--->
			
			<cfset thisnameprefix="adhoc-#arguments.formfield#-#l#-#arguments.stApprovalData.approvaldataid#-#arguments.responsedataid#">
			<cfset sReturn = sReturn & "<div>"> <!---#namestring(au.lastname,au.firstname)#">--->
			<cfif au.adhocid eq "" or au.adhocid eq 0><cfset au.adhocid = -1></cfif>
			<cfset sReturn = sReturn & '<input type="hidden" name="#thisnameprefix#-adhocid" value="#au.adhocid#">'>	

			<cfset sReturn = sReturn & '<input type="text" class="adhoc" name="#thisnameprefix#-firstname" value="#au.firstname#"  placeholder="Enter a first name." '>
			<cfif isnumeric(arguments.stApprovalData.adhocminimum) and v lte arguments.stApprovaldata.adhocminimum>
				<cfset possiblereview=possiblereview+1>
				<cfset sReturn = sReturn & " required " >
			</cfif>
			<cfset sReturn = sReturn & ' maxlength="255" >'>
			<cfset sReturn = sReturn & '<input type="text" class="adhoc" name="#thisnameprefix#-lastname" value="#au.lastname#"  placeholder="Enter a last name." '>
			<cfif isnumeric(arguments.stApprovalData.adhocminimum) and v lte arguments.stApprovaldata.adhocminimum>
				<cfset sReturn = sReturn & " required " >
			</cfif>
		
			<cfset sReturn = sReturn & ' maxlength="255" >'>

			<cfset sReturn = sReturn & '<input type="text" class="adhoc" name="#thisnameprefix#-department" value="#au.department#"  placeholder="Enter the department or company affiliation." '>
			<cfif isnumeric(arguments.stApprovalData.adhocminimum) and v lte arguments.stApprovaldata.adhocminimum>
				<cfset sReturn = sReturn & " required " >
			</cfif>
	
			<cfset sReturn = sReturn & ' maxlength="255" >'>

			<cfset sReturn = sReturn & '<input type="email" class="adhoc" name="#thisnameprefix#-email" value="#au.email#"  placeholder="Enter a valid email address." '>
			<cfif isnumeric(arguments.stApprovalData.adhocminimum) and v lte arguments.stApprovaldata.adhocminimum>
				<cfset sReturn = sReturn & " required " >
			</cfif>
			<cfset v = v+1>
			<cfset sReturn = sReturn & ' maxlength="255" >'>

			<cfset sReturn = sReturn & " <em>">
			<cfif structkeyexists(arguments.stReviews,au.usr)>
				<cfif arguments.stReviews[au.usr].responsetype eq 1>
					<cfset positivereivew = positivereview+1>
					<cfset sReturn = sReturn & "approved">
				<cfelse>
					<cfset sReturn = sReturn & "returned">
				</cfif>
			<cfelse>
				<cfset sReturn = sReturn & "not reviewed">
			</cfif>
			<cfset sReturn = sReturn & " </em>"&chr(13)&chr(10)>

			<cfif arguments.responsesetstatus gt 1 and (session.usr.usrid eq au.usr OR session.usr.accesslevel lte 2)>
				<!--- STUB: should this be a separate review page? --->
				<cfset sReturn = sReturn & '<a href="reviewadhoc.cfm?adhocid=#au.adhocid#" class="reviewbutton">[ Review ]</a>'>
		<!--- for debug	<cfelse>
				<cfset sReturn = sReturn & " #arguments.responsesetstatus# gt 1 and (#session.usr.usrid# eq #au.usr# or #session.usr.accesslevel# lte 2) "> --->
			</cfif>
			<cfset sReturn = sReturn & " <br clear='both' />">
		</cfloop>
	</cfif>

	<cfif structkeyexists(arguments.stapprovaldata,"adhocauthorizer") and isnumeric(arguments.stapprovaldata.adhocauthorizer)>

		<cfset possiblereview = possiblereview+1>
		<cfinvoke component="#application.modelpath#.usr" method="getUsr" usrid="#arguments.stapprovaldata.adhocauthorizer#" returnvariable="udata"></cfinvoke>
		<cfset sReturn = sReturn & "<div>Ad Hoc authorizer: #namestring(udata.lastname,udata.firstname)# &lt;#udata.email#&gt;">

		<cfset sReturn = sReturn & " <span class='approvaltype'>">
		<cfif structkeyexists(arguments.stReviews,arguments.stapprovaldata.adhocauthorizer)>
			<cfif arguments.stReviews[arguments.stapprovaldata.adhocauthorizer].responsetype eq 1>
				<cfset sReturn = sReturn & "approved">
				<cfset positivereview =positivereview+1>
			<cfelse>
				<cfset sReturn = sReturn & "returned">
			</cfif>
		<cfelse>
			<cfset sReturn = sReturn & "not reviewed">
		</cfif>
		<cfset sReturn = sReturn & " </span>">
		<cfif structkeyexists(arguments.stReviews,arguments.stapprovaldata.adhocauthorizer)>
			<cfset sReturn = sReturn & "<div class='commment'>" & arguments.stReviews[arguments.stapprovaldata.adhocauthorizer].approvalcomment & "</div>">
		</cfif>
		<cfset sReturn = sReturn & " </div>">
		<cfif arguments.printformat eq false>
			<!---<cfoutput>[#arguments.responsesetstatus#. #session.usr.usrid# .#arguments.stApprovalData.usr#]</cfoutput>--->
			<cfif arguments.responsesetstatus gt 1 and ( udata.usrid eq session.usr.usrid  OR session.usr.accesslevel lte 2)>
				<cfset sReturn = sReturn & '<a href="review.cfm?approvaldataid=#arguments.stApprovalData.approvaldataid#&responsedataid=#arguments.responsedataid#" class="reviewbutton">[ Review ]</a>'>
			</cfif>
		</cfif>	
	</cfif>
	
	
	<cfset sReturn = sReturn & "<div>#positivereview# approvals of #possiblereview#">
	
	<cfif arguments.approvaltype eq 2> <!--- any --->			
		<cfif possiblereview gt 0 and positivereview gt 0 >
			<cfset sReturn = sReturn & " (Satisfied)">
		<cfelse>
			<cfset sReturn = sReturn & " (Not Satisfied)">
		</cfif>
	<cfelseif arguments.approvaltype eq 1> <!--- all ---><cfoutput>showing as <cfdump var="#arguments.stApprovalData#"> #arguments.stApprovalData.satisfied#</cfoutput>
		<cfif possiblereview gt 0 and positivereview eq possiblereview>
			<cfset sReturn = sReturn & " (Satisfed)">
		<cfelse>
			<cfset sReturn = sReturn & " (Not Satisfied)">
		</cfif>
	</cfif>
	<cfset sReturn = sReturn & "</div>">

	

	<cfreturn sReturn>
</cffunction>
--->




<cffunction name="getApprovalDataForApprovalSet" output="false">
	<cfargument name="approvalset">

	<Cfset var qget = "">

	<Cfquery name="qget" >
	select approvaldata.*, usr.lastname, usr.firstname, usr.email, approvalgroup.approvalgroupname  from approvaldata 
	left outer join usr on usr.usrid = approvaldata.usr
	left outer join approvalgroup on approvalgroup.approvalgroupid = approvaldata.approvalgroup
	left outer join keyusroptiondata on keyusroptiondata.optiondata = approvaldata.optiondata

	where approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvalset#">
	order by approvaldata.approvaldataid
	</Cfquery>

	<Cfreturn qget>
</cffunction>
<!---<cffunction name="getapprovalsasstruct" output="false">
	<cfargument name="approvalset">
	<cfargument name="responsedata">

	<!--- STUB: this will need optimizing --->
	<cfset var qget = "">
	<cfset var stTemp = structnew()>
	
	<!--- STUB: add indexes --->
	<cfquery name="qGet" >
	select * from approval where approvalset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvalset#"> and responsedata=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedata#">
	</cfquery>
	
	<cfloop list="#qget.columnlist#" index="c">
		<cfset stTemp[c]= evaluate("qget.#c#")>
	</cfloop>

	<cfreturn stTemp>
</cffunction>--->
<cffunction name="getapprovalsetid" output="false">
	<cfargument name="approvaldataid">

	<cfset var qget = "">

	<cfquery name="qget" >
	select approvalset from approvaldata where approvaldataid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvaldataid#">
	</cfquery>

	<cfreturn qget.approvalset>
</cffunction>
<cffunction name="getdata" output="false">
	<cfargument name="id">
	<cfset var qqet = "">
	<cfquery name="qget" >
	select approvaldata.*, usr.lastname, usr.firstname, usr.email, approvalgroup.approvalgroupname, approvaldataid as id 
	from approvaldata 
	left outer join usr on usr.usrid = approvaldata.usr
	left outer join approvalgroup on approvalgroup.approvalgroupid = approvaldata.approvalgroup
	
	<cfif isnumeric(arguments.id)>
	where approvaldataid = #arguments.id#
	</cfif>
	</cfquery>
	<cfreturn qget>
</cffunction>
</cfcomponent>
