<cfsilent>
<cfif isdefined ("form.formid")>
	<cfset url.formid = form.formid>
</cfif>
<cfparam name="url.formid" type="integer">
<cfparam name="url.responsesetid" default="">
</cfsilent>
<!--- handle deleted responses --->
<cfif isdefined("url.action") and url.action eq "delete">
	<cfif isdefined("url.type") and url.type eq "responseset">
		<cfif isdefined("url.responsesetid") and isnumeric(url.responsesetid)>
			<cfinvoke component="#application.modelpath#.responseset" method="getdata" id="#url.responsesetid#" returnvariable="qResponseSet"></cfinvoke>
			<cfif qResponseSet.form eq url.formid>
				<cfif session.usr.accesslevel lte 2 OR session.usr.usrid eq qresponseset.creator>
					<cfinvoke component="#application.modelpath#.responseset" method="delete" id="#url.responsesetid#"></cfinvoke>
					<cflocation url="form.cfm?formid=#url.formid#" addtoken="no">
				<cfelse>
					<em>Insufficient privileges to delete.</em>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
</cfif>
<cfsilent>
<!--- collect information about this form, including the correct visibility --->
<cfinvoke component="#application.modelpath#.form" method="loadData" id="#url.formid#" returnvariable="f"></cfinvoke>
</cfsilent>

<cfif f.formid eq "">
	<em>I'm sorry, I can't find that form.</em>
<cfelse>
	<!--- formstatus is private or authenticated --->
	<cfif f.formstatus eq 2 or f.formstatus eq 4>
		<cfif not isdefined("session.usr")>
			<cflocation url="/login/index.cfm?returnto=/form.cfm&formid=#url.formid#">
		</cfif>
		<Cfif f.formstatus eq 2>
			<!--- this person must be an admin --->
			<cfif session.usr.accesslevel gte 3>
				<em>Error! I'm sorry, this form is private. You must have form editing privileges to view it.</em>
				<cfabort>
			</cfif>
		</Cfif>
		<!--- status is authenticated --->
	</cfif>

<!--- if the user has submitted, save the data --->
<cfif isdefined("form.submit")>
	<cfif listfindnocase("Save,Submit,Retract,Complete,Download",form.submit)>
	<!--- may need some addl data validation here --->

		<cfif isdefined("form.formid") and isnumeric(form.formid)>
			<!--- get the form fields --->
			<cfinvoke component="#application.modelpath#.responseSet" method="SaveResponseSet" returnvariable="url.responsesetid" formdata="#form#"></cfinvoke>
			
		</cfif>
		<cfif form.submit eq "Submit">
			<!--- submit action takes the form to the next step --->
			<cfinvoke component="#application.modelpath#.responseset" method="makeactive" responsesetid="#url.responsesetid#" formid="#url.formid#"></cfinvoke>
		<cfelseif form.submit eq "Retract">
			<cfinvoke component="#application.modelpath#.responseset" method="makeinactive" responsesetid="#url.responsesetid#" formid="#url.formid#"></cfinvoke>
		<cfelseif form.submit eq "Complete">
			<cfinvoke component="#application.modelpath#.responseset" method="makeComplete" responsesetid="#url.responsesetid#" formid="#url.formid#"></cfinvoke>
		<cfelseif form.submit eq "Download">
			<cflocation url="formaspdf.cfm?formid=#url.formid#&responsesetid=#url.responsesetid#" addtoken="no">
		</cfif>

	</cfif>
</cfif>

	<!--- if a responseset is specified, load it. 
		if not responseset is specified, see if this user has previously submitted the form.
		if this is a single submission form, use that record --->
		<cfif len(url.responsesetid) and not isnumeric(url.responsesetid)>
			Error! Invalid Responsesetid<cfabort>
		</cfif>

		<cfif isnumeric(url.responsesetid) >

			<Cfinvoke component="#application.modelpath#.responseset" method="getResponseSet" formid = "#url.formid#" responsesetid="#url.responsesetid#" returnvariable="qResponseSet" ></Cfinvoke>

			<cfif qResponseSet.responsesetid neq 0>
				<!---identify anyone who should have access to view/approve this form --->
				<cfinvoke component="#application.modelpath#.form" method="getAllApprovers" formid = "#url.formid#" returnvariable="lapproverUsrids" responsesetid="#url.responsesetid#"></cfinvoke>
			<cfelse>
				<cfset lapproverUsrids = "">
			</cfif>

			<cfif session.usr.accesslevel eq 3 and qResponseSet.creator neq session.usr.usrid and listfind(lApproverUsrids,session.usr.usrid) eq 0>
				Error! This account does not have access to this submission.<cfabort>
			</cfif>
			<cfif url.responsesetid neq 0 and qResponseSet.recordcount neq 1>
				<cfdump var="#url#">
				<cfdump var="#qresponseset#">
				Error! This is not a valid responsesetid.
				<cfabort>
			</cfif>
		<!---<cfelseif url.responsesetid eq 0>
			Forcing new submission.--->
		<cfelse>

			<cfinvoke component="#application.modelpath#.responseset" method="getResponseSets" usr="#session.usr.usrid#" form="#f.formid#" returnvariable="qResponseSet"></cfinvoke>

			<cfif qResponseSet.recordcount gt 0>
				<!--- let the user choose, if this form isn't single submission --->
				<cfif f.singlesubmission neq 1>
					<p>
					You have submitted this form previously. Please select a submission to open:
					<cfinvoke component="#application.modelpath#.responseset" method="submissionlist" responseset="#qResponseSet#" returnvariable="sResponseSetList"></cfinvoke>
					<cfoutput>
						#sResponseSetList#
						<br>
						<a href="form.cfm?formid=#url.formid#&responsesetid=0">[ New Submission ]</a>
					</cfoutput>
				</p>
				<!--- don't display the empty form? --->
				<cfabort>

				<cfelse>
					<cflocation url="form.cfm?formid=#url.formid#&responsesetid=#qResponseset.responsesetid#" addtoken="no">
				</cfif>
					<!--- if the form is single submission, the first submission will be used. --->
			</cfif>
		</cfif>
		<!--- load responsedata for this user --->
</cfif>


<!---<cfsilent>--->
<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfinvoke component="#application.modelpath#.form" method="getFormFieldsWithResponses" returnvariable="aFields" formid="#f.formid#" responsesetid="#qResponseSet.responsesetid#"></cfinvoke>
<!---</cfsilent>--->

<!--- Should they exist, find the matching responses --->
<!---<cfinvoke component="#application.modelpath#.responseset" method="getResponses" returnvariable="aFields" formfieldarray="#aFields#"></cfinvoke>--->

<cfif arrayIsEmpty(aFields)>
	<em>I'm sorry, this form contains no fields.</em>
<cfelse>
	<cfoutput>
		<form action="#cgi.SCRIPT_NAME#?formid=#url.formid#&responsesetid=#url.responsesetid#" method="post" enctype="multipart/form-data">
		<h2>#f.formname#</h2>
		<cfif isnumeric(url.responsesetid) and url.responsesetid gt 0>
			<cfif qResponseSet.responsesetstatus eq 1>
				<span class="dim">This form has not been submitted, and is not active.</span>
			<cfelse><cfsilent>
				<cfinvoke component="#application.modelpath#.usr" usrid="#qResponseset.creator#" returnvariable="submittingUsr" method="getusr"></cfinvoke>
				<cfinvoke component="#application.modelpath#.object" lastname="#submittingUsr.lastname#" firstname="#submittingUsr.firstname#" returnvariable="str" method="namestring"></cfinvoke>
				</cfsilent>
				<cfif len(str)>
					<span class="dim">Submitted by #str# #datetimeformat(qresponseset.datecreated, "long")#
						current status #qresponseset.responsesetstatusname#
					</span>
				</cfif>
			</cfif>
		</cfif>
<cfset pendingReview = false>
<cfif url.debug><cfdump var="#aFields#"></cfif>
	<cfloop from="1" to="#arraylen(aFields)#" index="t">	
		<!--- STUB: we need to handle the assignee option here --->
		#oWriter.write(fieldtype=aFields[t].fieldType,fieldName=aFields[t].label,stForm=f,formfieldid=aFields[t].formfieldid,fieldComment=aFields[t].fieldcomment,optionset=aFields[t].optionset,stResponse=aFields[t].stResponse,required=aFields[t].required,defaultvalue=aFields[t].defaultvalue,targetcolumn=aFields[t].targetcolumn)#
		<br />
		<cfif aFields[t].fieldType eq 7>
			<!--- this is an approval step. if it is not satisfied, we halt display of the form here. Because we have to get all the information about a given approval step, we'll just return all the data --->
			<cfif isnumeric(aFields[t].approvalset)>
				<label>#aFields[t].label#</label>
				<!---<cfloop from="1" to="#arraylen(aFields[t].stApprovalSet.aApprovalData)#" index="a"><cfsilent></cfsilent>
				<cfinvoke component="#application.modelpath#.approvaldata" method="drawApprovalData" responsedataid="#aFields[t].stResponse.responsedataid#" stapprovaldata="#aFields[t].stApprovalSet.aApprovalData[a]#" returnvariable="sApproval" responsesetstatus="#qResponseSet.responsesetstatus#" stReviews="#aFields[t].stReview#" formfield="#aFields[t].formfieldid#" approvaltype="#afields[t].stapprovalset.approvaltype#"></cfinvoke>
					</cfloop>--->
				<cfinvoke component="#application.modelpath#.approvalset" method="drawReviewField" returnvariable="sApproval" fielddata="#afields[t]#" responsedataid="#aFields[t].stResponse.responsedataid#" responsesetstatus="#qResponseset.responsesetstatus#"></cfinvoke>
				#sApproval# 
			
			<cfif aFields[t].stApprovalSet.satisfied eq false>
				<!--- do not continue writing the form until this condition has been satisifed. --->
				<cfset pendingReview = true>
					<cfbreak>				
			</cfif>

					<!--- satisfied, we display this approval --->
					<!---<cfinvoke component="#application.modelpath#.approvalset" method="drawApprovalSet" approvalset="#approvalset#" returnvariable="sApprovalSet"></cfinvoke>
					#sApprovalSet#--->
			
					<!--- not satisfied, we show an approval form to the right user  session.usr.usrid eq Approval.approvalusrid or--->
				<!---	<cfif  session.usr.accesslevel lte 2>
						<cfinvoke component="#application.modelpath#.approval" method="drawApprovalForm" returnvariable="sApprovalForm" ApprovalSet="#ApprovalSet#"></cfinvoke>
						#sApprovalForm#
					<cfelse>
						<!--- STUB: duplicate stretch of code here... could indicate logic opportunity --->
						<cfinvoke component="#application.modelpath#.approvalset" method="drawApprovalSet" approvalset="#approvalset#" returnvariable="sApprovalSet"></cfinvoke>
						#sApprovalSet#
					</cfif> --->
				<!---<cfif ApprovalSet.satisfied neq "yes">	

					<cfbreak> <!--- we break out of the loop --->
				</cfif>--->
				
			</cfif>
		</cfif>
	</cfloop>
		<br clear="both" />
		<hr>
	<fieldset>

<cfif url.debug eq 1>
		<div>To show, or not to show?
			access level #session.usr.accesslevel#
			responseset #qresponseset.responsesetid#
			pending review #pendingreview#
			creator #qresponseset.creator#
			this user #session.usr.usrid#
		</div>
</cfif>
		<cfif (session.usr.accesslevel lt 3 ) OR
			( qresponseset.responsesetid eq "" or qresponseset.responsesetstatus eq 1 )
				OR
		( (pendingReview eq false and f.formstatus gt 2)
		and ( session.usr.usrid eq qresponseset.creator) )>
			<p>
			<input type="submit" name="submit" value="Save" />
			<input type="submit" name="cancel" value="Cancel" />
			</p>
		</cfif>
		<!--- workflow controls --->
		<cfif (session.usr.accesslevel lt 2 or session.usr.usrid eq qresponseset.creator ) and qResponseset.responsesetid gt 0  and f.formstatus gt 2>
			<!--- workflow controls --->
			
			<cfswitch expression="#qResponseSet.responsesetstatus#">
				<cfcase value="1"> <!--- new --->
					<p>This submission is not active.
					If you are ready for this submission to be processed, click Submit-&gt;
					<input type="submit" name="submit" value="Submit" class="forward" />
					</p>
				</cfcase>
				<cfcase value="2"> <!--- data collection --->
					<p>This submission is active.
					If you want to resend workflow notices for the current step, click Submit-&gt;
					<input type="submit" name="submit" value="Submit" class="forward" /><br />
					If you want to remove this submission from processing, click Retract-&gt;
					<input type="submit" name="submit" value="Retract" class="backward" />
					<cfif session.usr.usrid eq f.finalAssignee>
						If you want to complete this submission, click Complete-&gt;
						<input type="submit" name="submit" value="Complete" class="forward" />
					</cfif>
					</p>
				</cfcase>
				<cfcase value="3"> <!--- approval; this should only occur
				for final review --->
					<p>This submission is in review.
					<cfif session.usr.accesslevel lte 2>
						If you want to complete this submission, click Submit-&gt;
						<input type="submit" name="submit" value="Complete" class="forward" />
					</cfif>
					</p>
				</cfcase>
				<cfcase value="4"> 
					<p>This submission is complete.
					If you want to recover this submission, click Retract-&gt;
					<input type="submit" name="submit" value="Retract" class="backward" /></p>
				</cfcase>
				<cfcase value="5">
					<p>This submission is marked as deleted.<br />
						If you want to recover this submission, click Retract-&gt;
					<input type="submit" name="submit" value="Retract" class="backward" /></p>
				</cfcase>
			</cfswitch>			
			
		</cfif>
		<cfif url.responsesetid neq 0>
			<input type="submit" name="submit" value="Download" />
		</cfif>
		<input type="hidden" name="formid" value="#url.formid#">
		<input type="hidden" name="responsesetid" value="#responsesetid#">

	</fieldset>
	
	</form>
	</cfoutput>
</cfif>


	<!--- get data about this form field --->
			<!---<cfif isnumeric(aFields[t].formfieldid)>
				<cfquery name="qFormField" >
				select * from formfield where formfieldid = <cfqueryparam cfsqltype="cf_sql_integer" value="#afields[t].formfieldid#">
				</cfquery>
			<cfelse>
				Error! invalid form field id <cfabort>
			</cfif>--->

<cfif (url.debug)>
	<cfdump var ="#f#">
</cfif>