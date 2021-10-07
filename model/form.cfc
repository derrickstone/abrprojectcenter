<cfcomponent extends="object" output="no">
<cfset this.type="form">
<cffunction name="delete">
	<cfargument name="id">

	<cfset var qdelform = "">
	<cfset var qdelformfield = "">
	<cfset var qdelkeyformgroupform = "">
	<cfset var qdelkeyformorganization = "">
	<cfset var qformfield = "">
	<cfset var qdelresponseset = "">
	<cfset var qdelresponsedata = "">

	<cfquery name="qdelkeyformorganization" datasource="#application.dsn#">
	delete from keyformorganization where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qdelkeyformgroupform" datasource="#application.dsn#">
	delete from keyformgroupform where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qformfield" datasource="#application.dsn#">
	select formfieldid from formfield where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qdelresponseset" datasource="#application.dsn#">
	delete from responseset where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qdelresponsedata" datasource="#application.dsn#">
	delete from responsedata where formfield in (<cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qformfield.formfieldid)#" list="true">)
	</cfquery>
	<cfquery name="qdelformfield" datasource="#application.dsn#">
	delete from formfield where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qdelform" datasource="#application.dsn#">
	delete from form where formid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfreturn "deleted">
</cffunction>
<cffunction name="getAllApprovers" output="false">
	<cfargument name="formid" >
	<cfargument name="responsesetid">
	<!--- <cfargument name="responsedata"> 
	<cfargument name="approvalsetid"> --->

	<cfset var qget = "">
	<cfset var lApprovers = "">

	<cfquery name="qget" datasource="#application.dsn#">
	select * from formfield inner join approvalset on approvalset.approvalsetid = formfield.approvalset
	inner join approvaldata on approvaldata.approvalset = approvalset.approvalsetid
	 where formfield.fieldtype = 7 
	 and formfield.form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
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
		<cfinvoke component="#application.modelpath#.adhoc" method="getmembers" returnvariable="qAdHocMembers" responsedata="#qget.responsedata#" approvaldata="#qget.approvaldataid#"></cfinvoke>
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

<!---<cffunction name="formFieldEditor">
	<cfargument name="formfieldid">

	<cfset var sReturn = "">
	<cfset var qGet = "">

	
	<cfsavecontent variable="sReturn"><cfoutput>
		<form action="#cgi.SCRIPT_NAME#" method="post">
			<input type="text" name="label" value="">
			<input type="submit" name="submit" value="submit">
		</form></cfoutput>
	</cfsavecontent>
	<cfreturn sReturn>
</cffunction>--->

<cffunction name="getFormFields">
	<cfargument name="formid">
	
	<cfset var qGet="">
	<cfset var aFields = "">
	
	<cfquery name="qGet" datasource="#application.dsn#">
	select * from formfield where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
	order by sortkey
	</cfquery>
	
	<cfset aFields = queryToArrayOfStructs(qGet)>
	
	<cfreturn aFields>

</cffunction>
<cffunction name="getFormFieldsWithResponses" output="false">
	<cfargument name="formid">
	<cfargument name="responsesetid">
	
	<cfset var qGet="">
	<cfset var aFields = "">
	<Cfset var qresponse = "">
	<cfset var f = "">
	<Cfset var stTemp = structnew()>
	
	<cfquery name="qGet" datasource="#application.dsn#">
	select * from formfield where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
	order by sortkey
	</cfquery>
	<cfset aFields = arraynew(1)>
	
	<cfloop query="qGet">
		<cfset stTemp = structNew()>
		<cfloop list="#qGet.columnlist#" index = "c">
			<cfset stTemp[c]=qGet[c]>
		</cfloop>			
	
		<!--- STUB: performance opportunity here --->
		<cfinvoke component="#application.modelpath#.responseData" method="getresponseasstruct" returnvariable="stTemp.stResponse" formfield="#qget.formfieldid#" responseset="#arguments.responsesetid#"></cfinvoke>
	
		<cfset stTemp.stApprovalSet = structnew()>
		<cfif isnumeric(qget.approvalset)>
			<!--- get the approvalset record --->
			<cfinvoke component="#application.modelpath#.approvalset" method="getdata" returnvariable="qApprovalSet" id="#qget.approvalset#" ></cfinvoke>
			<cfloop list="#qApprovalSet.columnlist#" index="c">
				<cfset stTemp.stApprovalSet[c]=qApprovalSet[c]>
			</cfloop>


			<!--- get all the reviews for this responsedata --->
			<cfinvoke component="#application.modelpath#.review" method="getReviews" 
				responsedata = "#stTemp.stResponse.responsedataid#"
				approvalset = "#stTemp.stApprovalSet.approvalsetid#"				
			returnvariable="qReviews"></cfinvoke>
			<!--- arrange these in a structure by usrid for easy access 
				this assumes only one review per usr per review step --->
			<cfset stTemp.stReview = structnew()>
			<cfloop query="qReviews">
				<cfset stTemp.stReview[qReviews.usr] = structnew()>
				<cfloop list="#qReviews.columnlist#" index="c">
					<cfset stTemp.stReview[qReviews.usr][c]=qReviews[c]>
				</cfloop>
			</cfloop>

			<!--- approvalsets can have multiple approvaldata records defining rules for that approval. These can include individual usr, approval groups or ad hoc approvers --->
			<cfinvoke component="#application.modelpath#.approvaldata" method="getApprovalDataForApprovalSet" approvalset="#qget.approvalset#" returnvariable="qApprovalData"></cfinvoke>
			
			<cfset stTemp.stApprovalSet.aApprovalData = queryToArrayOfStructs(qApprovalData)>
			<!--- this structure may have multiple requirements for this review
				to validate the response, we must loop over the array and check each rule --->
	
		<!--- total reviews are for the responseset --->
			<cfset stTemp.approvalSetReviews=0>
			<cfset stTemp.positiveApprovalSetReviews=0>


			<!--- get the reviewers based on the approvalset --->
			<cfloop from="1" to="#arraylen(stTemp.stApprovalSet.aApprovalData)#" index="p">
				<!--- possible reviews are for this responsedata --->	
				<cfset stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews = 0>
				<cfset stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews = 0>

				<cfset thisAD = stTemp.stApprovalSet.aApprovalData[p]>			 
				
				<cfif isnumeric(thisAD.usr) and thisAD.usr neq 0>
					
					<cfset stTemp.approvalSetReviews=stTemp.approvalSetReviews+1>
					<cfset stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews = stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews+1>
					<!--- asses the reviews 
						STUB: this really needs more cohesion 
						is the specified usr in the list of reviews?--->
					<cfset stTemp.stApprovalSet.aApprovalData[p].usrReview = structnew()>


					<!---there is only one usr record, so any and all approval types
						amount to the same requirement --->
					<cfif structkeyexists(stTemp.stReview,thisAD.usr)>
						<cfif stTemp.stReview[thisAD.usr].responsetype eq 1> <!--- approved --->
							<cfset stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews=stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews+1>
							<cfset stTemp.stApprovalSet.aApprovalData[p].usrReview.satisfied=true>
							<cfset stTemp.positiveApprovalSetReviews=stTemp.positiveApprovalSetReviews+1>
						<cfelse>
							<cfset stTemp.stApprovalSet.aApprovalData[p].usrReview.satisfied=false>
						</cfif>
					<cfelse>
						<cfset stTemp.stApprovalSet.aApprovalData[p].usrReview.satisfied=false>
					</cfif>
				</cfif>
				<cfif isnumeric(thisAD.approvalgroup) and thisAD.approvalGroup neq 0>
					<cfset stTemp.stApprovalSet.aApprovalData[p].approvalGroupReview = structnew()>
					<cfset stTemp.approvalSetReviews=stTemp.approvalSetReviews+1>
					<cfinvoke component="#application.modelpath#.approvalgroup" method="getmembers" approvalgroup="#thisAD.approvalgroup#" returnvariable="qApprovalGroup"></cfinvoke>
					<cfset stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews=stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews+qApprovalGroup.recordcount>
					
					<cfset stTemp.stApprovalSet.aApprovalData[p].aApprovalGroup=querytoarrayofstructs(qApprovalGroup)>

					<!--- asses the reviews --->
					<cfloop from="1" to="#arraylen(stTemp.stApprovalSet.aApprovalData[p].aApprovalGroup)#" index="n">							
						<cfif structkeyexists(stTemp.stReview,stTemp.stApprovalSet.aApprovalData[p].aApprovalGroup[n].usr)>
							<cfif stTemp.stReview[stTemp.stApprovalSet.aApprovalData[p].aApprovalGroup[n].usr].responsetype eq 1> <!--- approved --->
								<cfset stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews = stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews+1>									
							<cfelse>
								<cfif stTemp.stApprovalSet.approvaltypename eq "all">
									<cfset stTemp.stApprovalSet.aApprovalData[p].approvalGroupReview.satisfied=false>
								</cfif>
							</cfif>
						<cfelse>
							<cfset stTemp.stApprovalSet.aApprovalData[p].approvalGroupReview.satisfied=false>
						</cfif>
					</cfloop>
					<cfif stTemp.stApprovalSet.approvaltypename eq "any">
						<cfif stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews gt 0>
							<cfset stTemp.stApprovalSet.aApprovalData[p].approvalGroupReview.satisfied=true>
							<cfset stTemp.positiveApprovalSetReviews=stTemp.positiveApprovalSetReviews+1>
						<cfelse>
							<cfset stTemp.stApprovalSet.aApprovalData[p].approvalGroupReview.satisfied=false>
						</cfif>
					<cfelseif stTemp.stApprovalSet.approvaltypename eq "all">
						<cfif stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews eq stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews>
							<cfset stTemp.stApprovalSet.aApprovalData[p].approvalGroupReview.satisfied=true>
							<cfset stTemp.positiveApprovalSetReviews=stTemp.positiveApprovalSetReviews+1>
						<cfelse>
							<cfset stTemp.stApprovalSet.aApprovalData[p].approvalGroupReview.satisfied=false>
						</cfif>
					</cfif>
				</cfif>

				<cfif isnumeric(thisAD.adhocauthorizer) and thisAD.adhocauthorizer gt 0>
					<!--- we must first pass the authorizer review --->
					<cfset stTemp.stApprovalSet.aApprovalData[p].adHocAuthorizerReview = structnew()>
					<cfset stTemp.approvalSetReviews=stTemp.approvalSetReviews+1>
					<cfset stTemp.stApprovalSet.aApprovalData[p].adHocAuthorizerReview.satisfied=false>	
					<cfset stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews = stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews+1>
					
						
					<cfif structkeyexists(stTemp.stReview,thisAD.adhocauthorizer)>
						<cfif stTemp.stReview[thisAD.adhocauthorizer].responsetype eq 1>
							<cfset stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews = stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews+1>
							<cfset stTemp.stApprovalSet.aApprovalData[p].adHocAuthorizerReview.satisfied=true>
							<cfset stTemp.positiveApprovalSetReviews=stTemp.positiveApprovalSetReviews+1>
						</cfif>
					</cfif>

					<cfif isnumeric(thisAD.adhocnumber) and thisAD.adhocnumber gt 0>
						<cfset stTemp.stApprovalSet.aApprovalData[p].adHocGroupReview = structnew()>
				
						<cfset stTemp.stApprovalSet.aApprovalData[p].adHocGroupReview.satisfied=false>	
	
					<cfinvoke component="#application.modelpath#.adhoc" method="getmembers" returnvariable="qAdHocMembers" responsedata="#stTemp.stResponse.responsedataid#" approvaldata="#stTemp.stApprovalSet.aApprovalData[p].approvaldataid#" membercount="#thisAD.adhocnumber#"></cfinvoke>

					<!--- how many actual people are in this list?
					we only count ad hoc records filled in
					 --->
					<cfquery dbtype="query" name="qahcount">
					select * from qAdHocMembers where length(qAdHocMembers.email) > 0
					</cfquery>
					<cfset stTemp.approvalSetReviews=stTemp.approvalSetReviews+qahcount.recordcount>
					<cfset stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews = stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews+qahcount.recordcount>					

					<cfset stTemp.stApprovalSet.aApprovalData[p].aAdHocGroup=queryToArrayOfStructs(qAdHocMembers)>

					<cfloop query="qahcount">							
						<cfif structkeyexists(stTemp.stReview,qahcount.usr)>
							<cfif stTemp.stReview[qahcount.usr].responsetype eq 1>
								<cfset stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews = stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews+1>			
								<cfset stTemp.positiveApprovalSetReviews = stTemp.positiveApprovalSetReviews+1>					
							</cfif>							
						</cfif>
					</cfloop>
					<cfif stTemp.stApprovalSet.approvaltypename eq "any">
						<cfif stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews gt 0>
							<cfset stTemp.stApprovalSet.aApprovalData[p].adHocGroupReview.satisfied=true>								
						<cfelse>
							<cfset stTemp.stApprovalSet.aApprovalData[p].adHocGroupReview.satisfied=false>
						</cfif>
					<cfelseif stTemp.stApprovalSet.approvaltypename eq "all">
						<cfif stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews gt 0 and stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews eq stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews>
							<cfset stTemp.stApprovalSet.aApprovalData[p].adHocGroupReview.satisfied=true>									
						<cfelse>
							<cfset stTemp.stApprovalSet.aApprovalData[p].adHocGroupReview.satisfied=false>	
						</cfif>
					</cfif>
					<!---<cfoutput>#positivereviews# out of #possiblereviews# = #stTemp.stApprovalSet.aApprovalData[p].adHocGroupReview.satisfied#</cfoutput>--->
				</cfif>


				</cfif>
				
				<!--- start option data --->
				<cfif isnumeric(thisAD.optionData) and thisAD.optionData neq 0>			
					<!--- thisAD.optionData indicates an option set. We only create a review step
						if a user is related to the selected option
					get the user supplied value for the preceeding question containing this option set

						 --->
	
					<cfinvoke component="#application.modelpath#.responsedata" method="getpreviousselectedoption" optionset="#thisad.optiondata#" responseset="#stTemp.stResponse.responseset#" returnvariable="selectedoption" responsedata = "#stTemp.stResponse.responsedataid#"></cfinvoke>
					<cfif isnumeric (selectedoption)>
						<cfinvoke component="#application.modelpath#.optionData" method="getmembers" optiondata="#selectedoption#" returnvariable="qOptionData"></cfinvoke>
						<cfset stTemp.stApprovalSet.aApprovalData[p].optionDataReview = structnew()>
						
						<cfset stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews=stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews+qOptionData.recordcount>							

						<cfset stTemp.stApprovalSet.aApprovalData[p].aOptionData=querytoarrayofstructs(qOptionData)>

						<!--- asses the reviews --->
						<cfloop from="1" to="#arraylen(stTemp.stApprovalSet.aApprovalData[p].aOptionData)#" index="n">
							<cfif structkeyexists(stTemp.stReview,stTemp.stApprovalSet.aApprovalData[p].aOptionData[n].usr)>
								<cfif stTemp.stReview[stTemp.stApprovalSet.aApprovalData[p].aOptionData[n].usr].responsetype eq 1> <!--- approved --->
									<cfset stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews = stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews+1>	
									<cfset stTemp.positiveApprovalSetReviews=stTemp.positiveApprovalSetReviews+1>							
								</cfif>								
							</cfif>
						</cfloop>
						<cfif stTemp.stApprovalSet.approvaltypename eq "any">
							<cfif stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews gt 0>
								<cfset stTemp.stApprovalSet.aApprovalData[p].optionDataReview.satisfied=true>									
							<cfelse>
								<cfset stTemp.stApprovalSet.aApprovalData[p].optionDataReview.satisfied=false>
							</cfif>
						<cfelseif stTemp.stApprovalSet.approvaltypename eq "all">
							<cfif stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews gt 0 and positivereviews eq stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews>
								<cfset stTemp.stApprovalSet.aApprovalData[p].optionDataReview.satisfied=true>									
							<cfelse>
								<cfset stTemp.stApprovalSet.aApprovalData[p].optionDataReview.satisfied=false>
							</cfif>
						</cfif>
					</cfif>
				</cfif>

				<!--- end option data --->
			
			
				<!--- compute if this formfield is satisfied --->
				<cfif stTemp.stApprovalSet.approvaltypename eq "all">
				<!--- <cfoutput>#totalreviews# gt 0 and #totalreviews# eq #totalpositivereviews# ||</cfoutput> --->
					<cfif stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews gt 0 and stTemp.stApprovalSet.aApprovalData[p].approvalDataReviews eq stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews>
						<cfset stTemp.satisfied=true>
					<cfelse>
						<cfset stTemp.satisfied=false>
					</cfif>
				<cfelse>
					<cfif stTemp.stApprovalSet.aApprovalData[p].positiveApprovalDataReviews gt 0>
						<cfset stTemp.satisfied=true>
					<cfelse>
						<cfset stTemp.satisfied=false>
					</cfif>
				</cfif>
				
			</cfloop>
			<!--- compute if the form is satisfied overall --->
			<cfif stTemp.stApprovalSet.approvaltypename eq "all">
				<!--- <cfoutput>#totalreviews# gt 0 and #totalreviews# eq #totalpositivereviews# ||</cfoutput> --->
				<cfif stTemp.approvalSetReviews gt 0 and stTemp.approvalSetReviews eq stTemp.positiveApprovalSetReviews>
					<cfset stTemp.stApprovalSet.satisfied=true>
				<cfelse>
					<cfset stTemp.stApprovalSet.satisfied=false>
				</cfif>
			<cfelse>
				<cfif stTemp.positiveApprovalSetReviews gt 0>
					<cfset stTemp.stApprovalSet.satisfied=true>
				<cfelse>
					<cfset stTemp.stApprovalSet.satisfied=false>
				</cfif>
			</cfif>
		</cfif>
		<cfset arrayAppend(aFields,stTemp)>
	</cfloop>
	
	<cfreturn aFields>

</cffunction>
<cffunction name="getformurlfromresponsedataid">
	<cfargument name="responsedataid">
	<cfset var qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
	select formfield.form, responsedata.responseset from formfield inner join responsedata on responsedata.formfield = formfield.formfieldid 
	where responsedata.responsedataid = #arguments.responsedataid#
	</cfquery>

	<cfif qget.recordcount eq 0>
		<cfreturn "">
	<cfelse>
		<cfreturn "form.cfm?formid=#qget.form#&responseset=#qget.responseset#">
	</cfif>

	</cffunction>
<cffunction name="getFormsForFormGroup">
	<cfargument name="formgroup" default="">
	<cfargument name="formstatus" default="">

	<cfset var qget = "">
	
	<Cfquery name="qget" datasource="#application.dsn#">
		select formid, formname from form where 
		<cfif isnumeric(arguments.formgroup)>
			formid in ( select form from keyformgroupform where formgroup = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formgroup#"> )
		<cfelse>
			formid not in ( select distinct form from keyformgroupform )
		</cfif>
		<cfif len(arguments.formstatus)>
			and formstatus in (<cfqueryparam cfsqltype="integer" list="true" value="#arguments.formstatus#">)
		</cfif>
	</Cfquery>

	<cfreturn qget>
	</cffunction>
<cffunction name="getFormsForOrganization">
	<cfargument name="organization" default="">
	<cfset var qget = "">
	<cfif isnumeric(arguments.organization)>
		<Cfquery name="qget" datasource="#application.dsn#">
		select formid, formname from form where formid in ( select form from keyformorganization where organization = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.organization#"> )
		</Cfquery>
	<cfelse>
		<Cfquery name="qget" datasource="#application.dsn#">
		select formid, formname from form where formid not in ( select distinct form from keyformorganization )
		</Cfquery>
	</cfif>

	<cfreturn qget>
	</cffunction>

<!---<cffunction name="getSubmissionsForForm">
		<cfargument name="formid">

		<cfset var qget = "">

		<cfquery name="qget" datasource="#application.dsn#">
		select * from responseset where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
		order by datecreated desc
		</cfquery>

		<cfreturn qget>

	</cffunction>--->
<cffunction name="showEditingList">
	<cfargument name="qData">
	<cfargument name="type" default="#this.type#">
	<cfargument name="lAdditionalFields" default="">
	<Cfargument name="maxitems" default="">

	<cfset var sRetval = '<div class="post">'>

	<cfset var stFormStatus=lookUpStruct("formstatus")>
		
	
	<!--- or url.action neq "edit" or url.action neq "submissions" --->
		<cfif not isdefined("url.#arguments.type#id") >
			<cfif isnumeric(arguments.maxitems) and qdata.recordcount lt arguments.maxitems>
				<cfset sRetval = sRetval & "<article>"& drawItemForm(-1,"",arguments.type) & "</article>">
			<cfelse>
				<cfset sRetval = sRetval & "<div>Maximum number of forms reached (#arguments.maxitems#).</div>">
			</cfif>
		</cfif>
	<cfloop query="qdata">
		<cfif isdefined("url.#arguments.type#id") and url["#arguments.type#id"] eq qdata.id and isdefined("url.action") and url.action eq "edit">
			<cfset sRetval = sRetval & drawItemForm(qdata.id,qdata.name,arguments.type)>
		<cfelseif isdefined("url.#arguments.type#id") and url["#arguments.type#id"] eq qdata.id and isdefined("url.action") and url.action eq "submissions">
			<!---<cfset qResponseSet=getSubmissionsForForm(qdata.id)>--->
			<cfinvoke component="#application.modelpath#.responseset" method="getResponseSets" form="#qdata.id#" returnvariable="qResponseSet"></cfinvoke>
			<cfset sRetval = sRetval & submissionlist(qResponseSet)>	
		<cfelse>

			<cfset sRetval = sRetval & '<div> <a href="form.cfm?formid=#qdata.id#"><strong>#qdata.name#</strong></a> '>

			<cfif isnumeric(qdata.formstatus)>
				<cfset sRetval = sRetval & stFormstatus[qdata.formstatus] >
			<cfelse>
				<cfset sRetval = sRetval & "-" >
			</cfif>
<!---
			<cfset sRetval = sRetval & '<a href="form.cfm?formid=#qdata.id#">[ Open ]</a>'>--->
			<cfset sRetval = sRetval & '<a href="#cgi.SCRIPT_NAME#?#arguments.type#id=#qdata.id#&action=edit">[ Rename ]</a>'>
			<cfif len(arguments.lAdditionalFields)>
				<cfloop list="#arguments.lAdditionalFields#" index="item">
					<cfset sRetval = sRetval & "&nbsp;" & evaluate("qData.#item#")>
				</cfloop>
			</cfif>
			<!--- STUB: add confirmations --->
			<cfset sRetval = sRetval & '&nbsp;<a href="#cgi.SCRIPT_NAME#?type=#arguments.type#&#arguments.type#id=#qdata.id#&action=delete" onClick="javascript: return confirm(''delete this item?'')">[ Delete ]</a>'>
			<cfset sRetval = sRetval & '&nbsp;<a href="#cgi.SCRIPT_NAME#?type=#arguments.type#&#arguments.type#id=#qdata.id#&action=configure">[ Configure ]</a>'>
			<cfset sRetval = sRetval & '&nbsp;<a href="submissions.cfm?#arguments.type#id=#qdata.id#">[ Submissions ]</a>'>
			<cfset sRetval = sRetval & '</div>'>
		</cfif>
	</cfloop>
	<cfset sRetval = sRetval & "</div>">
	<cfreturn sRetval>

	</cffunction>
	
	
<cffunction name="write" output="false">
	<cfargument name="fieldType">
	<cfargument name="fieldName" default="">
	<cfargument name="fieldLabel" default="">
	<cfargument name="formfieldid" default="">
	<cfargument name="stForm">
	<cfargument name="optionData" default="">
	<cfargument name="optionSet" default="">
	<cfargument name="readonly" default="">
	<cfargument name="required" default="">
	<cfargument name="placeholder" default="">
	<cfargument name="fieldcomment" default="">
	<cfargument name="sortOrder" default="">
	<cfargument name="htmlid" default="">
	<cfargument name="abbrcolumn" default="">
	<cfargument name="targetcolumn" default="s">
	<cfargument name="stResponse" default="">
	<cfargument name="defaultvalue" default="">

	<cfset var sReturn = "<div>">
		<cfset var sFormControl = "">
	<cfset var currentValue = "">
	<cfset var qGetData = "">

	<cfif len(arguments.fieldName & arguments.formfieldid) eq 0>
		Error! Field name or ID must be specified.<cfabort>
	</cfif>
	
	<!--- STUB: add logic to make fields readonly
	if the current user does not have permission to edit  --->
<!---
	<cfset sReturn = sReturn & formControl(fieldType=arguments.fieldType,fieldName=arguments.fieldName,fieldLabel=arguments.fieldLabel,optionData=arguments.optionData,optionSet=arguments.optionSet,stForm=arguments.stForm,readonly=readonly,placeholder=arguments.placeholder,htmlid=arguments.htmlid,formfieldid=arguments.formfieldid,sortOrder=arguments.sortOrder,abbrcolumn=arguments.abbrcolumn,targetcolumn=arguments.targetcolumn,stResponse=arguments.stResponse,required=arguments.required,defaultvalue=arguments.defaultvalue)>
 --->

 	<cfif isnumeric(arguments.fieldType)>
 		<cfinvoke component="#application.modelpath#.formfield" method="getFieldTypeFromId" formfieldtypeid="#arguments.fieldType#" returnvariable="sFieldType"></cfinvoke>
 	<cfelse>
 		<cfset sFieldType=arguments.fieldType>
 	</cfif>
 	
	<cfinvoke component="#application.modelpath#.formcontrol.#sFieldType#" method="draw" argumentcollection="#arguments#" returnvariable="sFormControl"></cfinvoke>

	<cfset sReturn = sReturn & sFormControl>

	<cfif len(arguments.fieldcomment)>
		<cfset sReturn = sReturn & "<div>"& arguments.fieldcomment&"</div>">
	</cfif>
	<cfset sReturn = sReturn & "</div>">

	<cfreturn sReturn>
</cffunction>
</cfcomponent>
