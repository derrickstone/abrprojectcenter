<cfcomponent extends="object">
<cfset this.type="noticequeue">
<cfset systemadminemail="admin@setcomposer.com">
<Cfset systemmailbox="uvaseas@setcomposer.com">
<cfset systempassword="t6YUM****T">
<cfset smtphost="smtp.mail.us-east-1.awsapps.com">
<cfset imaphost="imap.mail.us-east-1.awsapps.com">
<cffunction name="cancelNotices">
	<cfargument name="responseset">

	<Cfset var qClear = "">

	<cfquery name="qClear" datasource="#application.dsn#">
	update noticequeue set noticequeuestatus = 3, datelastupdated = '#datetimeformat(now())#'
		where responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responseset#"> and noticequeuestatus = 2
	</cfquery>
</cffunction>
<cffunction name="generateError">
	<cfargument name="to">
	<cfargument name="message">

	<!---
	To avoid confusion, I'll trim off the auto text --->
	<cfif find("---------",arguments.message) neq 0>
		<cfset arguments.message = left(arguments.message,find("---------",arguments.message))>
	</cfif>
	<cfmail to="#arguments.to#" from="#systemmailbox#" subject="Error reading email review" server="#smtphost#"  username="#systemmailbox#" password="#systempassword#" usessl="true" usetls="true" port="465">An error was encoutered trying to parse your email response. Please log in to setcomposer and record your review.
		#arguments.message#</cfmail>

</cffunction>
<cffunction name="generateNotice">
	<cfargument name="form">
	<cfargument name="formfield">
	<cfargument name="responseset">
	<cfargument name="responsedata">
	<cfargument name="assignee">
	<cfargument name="messagetype">
	<cfargument name="approvaldata">

	<cfset var qIns = "">
	<cfset var qCheck = "">

	<cfif arguments.form eq "" or arguments.form lt 0>
		Error! Cannot send a notice for a form that does not exist.<cfabort>
		<!--- STUB: notify the administrator --->
	</cfif>

	<cfloop list="#arguments.assignee#" index="u">
		<!--- prevent duplicates --->
		<Cfquery name="qCheck" datasource="#application.dsn#">
		select * from noticequeue where 
		usr =<cfqueryparam cfsqltype="cf_sql_integer" value="#u#"> and
		responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responseset#"> 
		and ( noticequeuestatus = 1 
			or (responsedata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedata#"> and noticequeuestatus = 2)
			)		
		</Cfquery>
		<cfif qCheck.recordcount eq 0>
			<cfquery name="qIns" datasource="#application.dsn#">
			insert into noticequeue ( form, formfield, responseset, responsedata, usr, noticequeuestatus, messagetype, approvaldata ) values (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.form#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfield#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responseset#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedata#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#u#">,
			1,
			 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.messagetype#">,
			 <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvaldata#">
			)
			</cfquery>
		</cfif>
	</cfloop>

</cffunction>
<cffunction name="isAlreadyReviewed">
	<cfargument name="reviewer">
	
	<cfargument name="responsedata">
	<cfargument name="approvaldata">

	<cfset var qget = "">
	<!--- if the user has already filed a review for this step, they do not need to be notified --->

	<cfquery name="qget" datasource="#application.dsn#">
	select reviewid from review where 
	usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reviewer#"> and
	
	responsedata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedata#"> and
	approvaldata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.approvaldata#">
	</cfquery>

	<cfreturn qget.recordcount>
	</cffunction>
<cffunction name="isnotautoreply">
	<cfargument name="subject">

	<cfif arguments.subject contains "undeliverable" or arguments.subject contains "out of office" or arguments.subject contains "vacation" or arguments.subject contains "Undelivered" or arguments.subject contains "returned to sender" or arguments.subject contains "delivery failure">
		<cfreturn false>
	</cfif>
	<cfreturn true>
</cffunction>

<cffunction name="notifyapprovalset">
	<cfargument name="approvalset">
	<cfargument name="responsedata">
	<cfargument name="debug" default="true">

	<cfset var qApprovalSet = "">
	<cfset var qForm = "">

	<!--- getting the responsedata record --->
	<Cfquery name="qForm" datasource="#application.dsn#">
		select responsedata.responsedataid, responsedata.responseset, responsedata.formfield, responseset.form from responsedata 
		inner join responseset on responsedata.responseset = responseset.responsesetid
		where responsedataid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedata#">
	</Cfquery>
	<!--- get the approvalset record --->
	<cfinvoke component="#application.modelpath#.approvalset" method="getData" id="#arguments.approvalset#" returnvariable="qApprovalSet"></cfinvoke>
	<!--- this gets the users specified as reviewers for usr, approvalgroup or option data --->
	<cfinvoke component="#application.modelpath#.approvaldata" method="getapprovaldataforapprovalset" approvalset="#qApprovalSet.approvalsetid#" returnvariable="qApprovalData"></cfinvoke>

	<!--- do stuff to get all the users who need to be notified 
		we should also check to make sure they haven't already approved, or been notified! --->
	<cfset lUsrs = "">
	<cfloop query="qApprovalData">
		<Cfif isnumeric(qApprovalData.usr) and qApprovalData.usr neq 0>
			<cfif not listfind(lUsrs,qapprovaldata.usr)>
				<cfif arguments.debug><cfoutput>Adding user #qapprovaldata.usr#</cfoutput></cfif>
				<cfset lUsrs=listappend(lUsrs,qApprovalData.usr)>
				<cfset generatenotice(form=qForm.form,formfield=qform.formfield,assignee=qapprovaldata.usr,responseset=qform.responseset,responsedata=arguments.responsedata,messagetype=1,approvaldata=qapprovaldata.approvaldataid)>
			</cfif>
		</Cfif>
		<cfif isnumeric(qApprovalData.approvalgroup) and qApprovalData.approvalGroup neq 0>

			<cfinvoke component="#application.modelpath#.approvalgroup" method="getMembers" approvalgroup="#qApprovalData.approvalgroup#" returnvariable="qMembers"></cfinvoke>
			<cfloop query="qMembers">
				<cfif arguments.debug><cfoutput>Adding group member #qapprovaldata.usr#</cfoutput></cfif>
				<Cfif isnumeric(qMembers.usr) and not listfind(lUsrs,qMembers.usr)>
					<cfset lUsrs=listappend(lUsrs,valuelist(qMembers.usr))>
					<cfset generatenotice(form=qForm.form,formfield=qform.formfield,assignee=qMembers.usr,responseset=qform.responseset,responsedata=arguments.responsedata,messagetype=1,approvaldata=qapprovaldata.approvaldataid)>
				</Cfif>
			</cfloop>
		</cfif>
		<cfif isnumeric(qApprovalData.optiondata) and qApprovalData.optiondata neq 0>
			<!--- get the usr response --->
			<cfinvoke component="#application.modelpath#.responsedata" method="getpreviousselectedoption" optionset="#qApprovalData.optiondata#" responseset="#qForm.responseset#" returnvariable="selectedoption" responsedata = "#arguments.responsedata#"></cfinvoke>
				<cfif isnumeric (selectedoption)>
					<cfinvoke component="#application.modelpath#.optiondata" method="getMembers" optiondata="#selectedoption#" returnvariable="qMembers"></cfinvoke>
					<cfloop query="qMembers">
						<cfif arguments.debug><cfoutput>Adding selected option #qmembers.usr#</cfoutput></cfif>
						<cfif isnumeric(qmembers.usr) and not listfind(lusrs,qmembers.usr)>

							<cfset lUsrs=listappend(lUsrs,qMembers.usr)>
							<cfset generatenotice(form=qForm.form,formfield=qform.formfield,assignee=u,responseset=qform.responseset,responsedata=arguments.responsedata,messagetype=1,approvaldata=qapprovaldata.approvaldataid)>
						</cfif>
					</cfloop>
				</cfif>
		</cfif>
		
		<cfif isnumeric(qApprovalData.adhocnumber) and qApprovalData.adhocnumber gt 0>
			<cfif isnumeric(qapprovaldata.approvaldataid) and isnumeric(arguments.responsedata)>
				<!--- add a notice for the authorizer --->
				<cfif isnumeric(qApprovalData.adhocauthorizer)>
					<cfif not listfind(lusrs,qapprovaldata.adhocauthorizer) and not isAlreadyReviewed(reviewer=qapprovaldata.adhocauthorizer,responsedata=arguments.responsedata,approvaldata=qapprovaldata.approvaldataid)>

						<cfif arguments.debug><cfoutput>Adding user #qapprovaldata.adhocauthorizer#</cfoutput></cfif>
						<cfset lusrs = listappend(lusrs,qapprovaldata.adhocauthorizer)>
						<cfset generatenotice(form=qForm.form,formfield=qform.formfield,assignee=qapprovaldata.adhocauthorizer,responseset=qform.responseset,responsedata=arguments.responsedata,messagetype=1,approvaldata=qapprovaldata.approvaldataid)>
					</cfif>
				</cfif>
				<!--- validate if the authorizer has indeed authorized this list --->
				<cfinvoke component="#application.modelpath#.adhoc" method="checkAuthorization" authorizer="#qapprovaldata.adhocauthorizer#" responsedata="#arguments.responsedata#" approvaldata="#qapprovaldata.approvaldataid#" returnvariable="isAuthorized">
				</cfinvoke>
				<cfif (isAuthorized)>
					<!--- get the members of this ad hoc group --->
					<cfinvoke component="#application.modelpath#.adhoc" method="getMembers" approvaldata="#qApprovalData.approvaldataid#" responsedata="#arguments.responsedata#" returnvariable="qMembers"></cfinvoke>

					<cfloop query="qMembers">
						<cfif isnumeric(qmembers.usr) and not listfind(lusrs,qmembers.usr)>
							<cfif arguments.debug>Adding user #qmembers.usr#</cfif>
							<cfset lUsrs=listappend(lUsrs,qMembers.usr)>
							<cfset generatenotice(form=qForm.form,formfield=qform.formfield,assignee=qmembers.usr,responseset=qform.responseset,responsedata=arguments.responsedata,messagetype=1,approvaldata=qapprovaldata.approvaldataid)>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfif>
		
	</cfloop>
	<!---<cfloop list="#lUsrs#" index="u">
		<cfif isnumeric(u)>
			<cfset generatenotice(form=qForm.form,formfield=qform.formfield,assignee=u,responseset=qform.responseset,responsedata=arguments.responsedata,messagetype=1)>
		</cfif>
	</cfloop>--->

</cffunction>

<cffunction name="notifycreatorofcompletion">
		<cfargument name="responsesetid">

		<cfset var qCreator = "">

		<Cfquery name="qCreator" datasource="#application.dsn#">
		select form, creator from responseset where responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
		</Cfquery>


		<cfif qCreator.recordcount eq 0>
			Error! No creator for this response!<cfabort>
		</cfif>
		<cfset generatenotice(form=qcreator.form,assignee=qcreator.creator,responseset=arguments.responsesetid,responsedata=-1,messagetype=3)>
</cffunction>
<cffunction name="notifyfinalassignee">
		<cfargument name="responsesetid">

		<cfset var qFinalAssignee = "">

		<Cfquery name="qFinalAssignee" datasource="#application.dsn#">
		select form.formid, form.finalassignee from form inner join responseset on responseset.form = form.formid where responseset.responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
		</Cfquery>


		<cfif qFinalAssignee.recordcount eq 0>
			Error! No final assignee for this form!<cfabort>
		</cfif>
		<cfset generatenotice(form=qfinalassignee.formid,assignee=qfinalassignee.finalassignee,responseset=arguments.responsesetid,responsedata=0,messagetype=2)>
</cffunction>
<cffunction name="processinbox">
		<!--- put users on hold who bounce mail --->
<!---<cftry>--->

	<cfimap server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#" action="getAll">
	<!--- STUB: handle attachments --->
	<cfif qmail.recordcount gt 0>
		<em>Processing <cfoutput>#qmail.recordcount# messages </cfoutput></em><br />
	
		<cfloop query="qmail">
			<!--- catch and handle auto replies --->
			<cfif isnotautoreply(qmail.subject) eq false>
				bounced mail<br />
				If this user exists, mark this user as on hold<br />
				<cfquery name="qlookup" datasource="#application.dsn#">
				select usrid from usr where email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qmail.from#">
				</cfquery>
				<cfif qlookup.recordcount eq 1>
					<cfquery name="qupdate" datasource="#application.dsn#">
					update usr set onhold = onhold+1 where usrid = #qlookup.usrid#
					</cfquery>
				</cfif>
				delete this message from the server <br />
				<cfimap action="delete" uid="#qmail.uid#" server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#">
			<cfelse>
				<!--- handle email submissions --->
			
				<cfset firstline=listfirst(qmail.textbody,chr(13)&chr(10))>
				
				<cfif findnocase("approve",firstline)>
					<cfset actionword = "approve">
					Reading an emailed-in approval.
				<cfelseif findnocase("return",firstline)>
					<cfset actionword="return">
					Reading an emailed-in return.
				<cfelse>
					<cfset actionword="">
				</cfif>
			
				<cfset stReview = structnew()>
				<cfset stReview.type = "review">
				<cfset newmessageend = find("---------",qmail.body)>
				<cfif newmessageend neq 0>
					<cfset stReview.approvalcomment = left(qmail.body,newmessageend)>
				</cfif>
				<cfset stReview.reviewid = -1>
				<cfset findlt = find("<",qmail.from)>
				<cfif findlt neq 0> <!--- this email includes the name --->
					<Cfset stReview.email = mid(qmail.from,findlt+1,find(">",qmail.from)-(findlt+1))>
				<cfelse>
					<Cfset stReview.email = qmail.from>
				</Cfif>
				<cfif isvalid("email",stReview.email)>
					Looking up user <input type="text" value="<cfoutput>#streview.email#</cfoutput>">
					<cfinvoke component="#application.modelpath#.usr" method="getusridfromemail" email="#streview.email#" returnvariable="stReview.usr"></cfinvoke>
					<!--- actually think this will have no effect, as creator is a reserved field --->
					<cfset stReview.creator=stReview.usr>
				</cfif>
				

				<cfif isnumeric(stReview.usr) and 
					uid neq 0 and 
					find("{",qmail.subject) neq 0 and
					find("}",qmail.subject) neq 0>
				
					
					<!--- parse two id values from the url within the original message --->
					<cfset identifiers = mid(qmail.subject,find("{",qmail.subject),find("}",qmail.subject))>
					<Cfset approvaldataid=listfirst(identifiers)>
					<!--- trim out the braces --->
					<cfset approvaldataid = right(approvaldataid,len(approvaldataid)-1)>
					<cfset responsedataid=listlast(identifiers)>
					<cfset responsedataid = left(responsedataid,len(responsedataid)-1)>
					reading email review for <cfoutput>responsedata #responsedataid# approvaldata #approvaldataid#</cfoutput>
					
					<!--- STUB: validate user has correct access for this review! --->
					<cfif isnumeric(responsedataid) and isnumeric(approvaldataid)>
						<cfset stReview.responsedata = responsedataid>
						<cfset stReview.approvaldata = approvaldataid>
						<!--- gotten this far - we will need the form id to save the approval
						this also kind of helps with security... maybe we should validate user
						permissions here as well...?  --->
						<cfinvoke component="#application.modelpath#.responsedata" method="getformid" responsedataid="#responsedataid#" returnvariable="stReview.formid"></cfinvoke>
						<cfinvoke component="#application.modelpath#.responsedata" method="getformfieldid" responsedataid="#responsedataid#" returnvariable="stReview.formfield"></cfinvoke>

						<cfif isnumeric(stReview.formid)>
							<cfif actionword eq "approve" or actionword eq "approved">					
								<cfset stReview.responseType = 1>
												
								<cfinvoke component="#application.modelpath#.review" method="handleEditForm" formdata="#stReview#" returnvariable="sMessage"></cfinvoke>
								<cfoutput>#sMessage#</cfoutput>
							<cfelseif actionword eq "return" or actionword eq "returned">
								<cfset stReview.responseType = 0>
								<cfif structkeyexists(stReview,"approvalcomment") and len(stReview.approvalcomment)>
									<cfinvoke component="#application.modelpath#.review" method="handleEditForm" formdata="#stReview#" returnvariable="sMessage"></cfinvoke>
									<cfoutput>#sMessage#</cfoutput>
								<cfelse>
									could not read an approval comment for a returned submission
									<cfset generateError(to=qmail.from,message=qmail.body)>
									<cfimap action="delete" uid="#qmail.uid#" server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#">
								</cfif>
							<cfelse>
								no action word identified for this message
								<!--- error message, could not parse this --->
								<cfset generateError(to=qmail.from,message=qmail.body)>		
								<cfimap action="delete" uid="#qmail.uid#" server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#">				
							</cfif>
						<cfelse>
							Error! invalid responsedataid - could not find a matching form id.
							<cfdump var="#stReview#">
							<cfset generateError(to=qmail.from,message=qmail.body)>
							<cfimap action="delete" uid="#qmail.uid#" server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#">
						</cfif>
					<cfelse>
						resposnedata or approvaldata identifiers not numeric
						<cfset generateError(to=qmail.from,message=qmail.body)>
						<cfimap action="delete" uid="#qmail.uid#" server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#">
					</cfif>
			
					<!--- STUB: might be nice to better validate this user has access to these identifiers --->
					<cfimap action="delete" uid="#qmail.uid#" server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#">
				
				<cfelse>
					could not find identifiers in the subject line
					<!--- error! --->
					<cfset generateError(to=qmail.from,message=qmail.body)>
					<cfimap action="delete" uid="#qmail.uid#" server="#imaphost#" secure="true" name="qmail"  username="#systemmailbox#" port="993" password="#systempassword#">
				</cfif>
	
			</cfif>		
		</cfloop>
	<cfelse>
		<em>No messages to process </em><br />
	</cfif>
<!---	<cfcatch type="any">
<cfmail to="#systemadminemail#" from="#systemmailbox#" subject="System error" server="#smtphost#"  username="#systemmailbox#" password="#systempassword#" usessl="true" usetls="true" port="465">An error was encoutered while processing setcomposer mail. #error.message#</cfmail>
	</cfcatch>
</cftry>
--->

</cffunction>
	<cffunction name="processnotices">

		<cfset var qget = "">
		<Cfset var tempfolder=expandpath("./pdf")>


		<!--- prepare the folder if it doesn't exist; empty it if it does --->
		<cfif not directoryexists(tempfolder)>
			<cfdirectory directory="#tempfolder#" action="create">
			directory created<br>
		<cfelse>
			<cfdirectory directory="#tempfolder#" action="list" name="qdir">
			<cfloop query="qdir">
				<cffile action="delete" file="#tempfolder#/#qdir.name#">
			</cfloop>
			directory emptied<br>
		</cfif>

		<cfquery name="qget" datasource="#application.dsn#">
		select noticequeue.*, usr.email from noticequeue inner join usr on usr.usrid = noticequeue.usr

		where noticequeue.noticequeuestatus = 1 and usr.holdmail = 0
		</cfquery>

		<cfif qget.recordcount>
			<!--- generate a pdf of the current state of the form  --->
			
			<cfloop query="qget">
	<!---<cftry>--->
				Sending to <cfoutput>#qget.email#</cfoutput>, generating pdf format.<br>
				<!--- send this message --->
				<!--- if we don't have a file to attach, generate it --->
				<cfset thisfile = tempfolder&"/form#qget.form#-#qget.responseset#.pdf">

				<!---
				<cfif not fileexists(thisfile)>
					<cfhttp method="get" url="http://localhost/formaspdf.cfm?formid=#qget.form#&responsesetid=#qget.responseset#" getasbinary="true" file="#thisfile#"></cfhttp>
					generated.
				<cfelse>
					File exists.
				</cfif>
				--->
				<cfinvoke component="#application.modelpath#.messagetype" method="generateMessage" messagetypeid="#qget.messagetype#" returnvariable="sMessage" linktext="http://#cgi.server_name#/form.cfm?formid=#qget.form#&responsesetid=#qget.responseset#"></cfinvoke>
				<!--- attach a copy of the form for the workflow step --->
				<cfif qget.messagetype neq 2>
					<cfinvoke component="#application.modelpath#.responseset" method="printableversion" formid="#qget.form#" responsesetid="#qget.responseset#" returnvariable="sResponseSet"></cfinvoke>

					<cfif len(sResponseSet)> 

						<cfdocument format="pdf" filename="#thisfile#"><cfoutput>#sResponseSet#</cfoutput></cfdocument>
						<cfmail to="#qget.email#" from="#systemmailbox#" subject="Workflow Notice: Task Awaiting {#qget.approvaldata#,#qget.responsedata#}" server="#smtphost#" port="465" usetls="yes" usessl="yes" username="#systemmailbox#" password="#systempassword#">#sMessage#
						
							<cfmailparam file="#thisfile#">
						
						</cfmail>
						<!--- mark this message as sent --->

						<cfquery name="qupdate" datasource="#application.dsn#">
						update noticequeue set noticequeuestatus=2 where noticequeueid = #qget.noticequeueid#
						</cfquery>

					<cfelse> <!--- file did not generate, form may have been deleted --->
						<!--- cancelled --->
						<cfquery name="qupdate" datasource="#application.dsn#">
						update noticequeue set noticequeuestatus=3 where noticequeueid = #qget.noticequeueid#
						</cfquery>

					</cfif>

				<cfelse> <!--- not attaching a copy of the submission --->
					<cfmail to="#qget.email#" from="#systemmailbox#" subject="Workflow Notice: Task Awaiting {#qget.approvaldata#,#qget.responsedata#}" server="#smtphost#" port="465" usetls="yes" usessl="yes" username="#systemmailbox#" password="#systempassword#">#sMessage#
			
					</cfmail>
					<!--- mark this message as sent --->

					<cfquery name="qupdate" datasource="#application.dsn#">
					update noticequeue set noticequeuestatus=2 where noticequeueid = #qget.noticequeueid#
					</cfquery>
				</cfif>
				
		<!---			<cfcatch type="any">
					<cfmail to="#systemadminemail#" from="#systemmailbox#" subject="System error" server="#smtphost#"  username="#systemmailbox#" password="#systempassword#" usessl="true" usetls="true" port="465">An error was encoutered while processing setcomposer mail.</cfmail>
						</cfcatch>
					</cftry> --->
			</cfloop>
		<cfelse>
			Nothing to process.
		</cfif>
		
	</cffunction>
</cfcomponent>