<cfcomponent extends="object">
	<cfset this.type="responseset">

<cffunction name="delete">
	<cfargument name="id" >

	<cfset var qdel1 = "">
	<cfset var qdel2 = "">
	<cfset var qdel3 = "">
	<cfset var qdel4 = "">
	<cfset var qget = "">
	<cfset var qget2 = "">

	<cfif not isnumeric(arguments.id)>
		Error! Invalid ID<cfabort>
	</cfif>

	<cfquery name="qget" >
	select * from responsedata where responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#"> and length(filepath) > 0
	</cfquery>
	<cfif qget.recordcount>
		<!--- this item has an attached file, we should delete it --->
		<cfinvoke component="#application.modelpath#.fileattachment" method="gettargetpath" responseset="#arguments.id#" formfield="#qget.formfield#" returnvariable="targetpath">
		<cfloop query="qget">
			<cfif fileexists(targetpath & "/" & qget.filepath)>
				<cflock name="filedellock" timeout="10" type="exclusive">
					<cffile action="delete" file="#targetpath#/#qget.filepath#">
				</cflock>			
			</cfif>
		</cfloop>
	</cfif>

	<cfquery name="qget2" >
	select responsedataid from responsedata where responseset = #arguments.id#
	</cfquery>
	<!--- STUB: should this be un-deletable? --->
	<cfquery name="qdel1" >
	delete from responsedata where responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfif qget2.recordcount>
		<cfquery name="qdel3" >
		delete from review where responsedata in ( <cfqueryparam cfsqltype="cf_sql_integer" value="#valuelist(qget2.responsedataid)#" list="true"> )
		</cfquery>
	</cfif>
	<cfquery name="qdel2" >
	delete from responseset where responsesetid =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qdel4" >
	delete from adhoc where responseset =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<!--- STUB: we should also delete attached files --->

	<cfreturn "Response Set Deleted">
</cffunction>
<cffunction name="getalluserselectedoptionapprovers">
	<cfargument name="responseset">

	<Cfset var qget = "">

	<cfquery name="qget" >
	select keyusroptiondata.usr
	from keyusroptiondata inner join responsedata on keyusroptiondata.optiondata = responsedata.numericresponse
	inner join formfield on formfield.formfieldid = responsedata.formfield
	where formfield.optionset <> 0 
	-- and formfield.optionset <> ''
	and responseset = #arguments.responseset# 

	</cfquery>
	<cfreturn valuelist(qget.usr)>
</cffunction>
<!---
<cffunction name="getApprovers">
	<cfargument name="responsesetid">

	<cfset var qget = "">

	<!--- get all approval steps for the form, and all the usrids --->
	<!---
	<Cfquery name="qget" >


	</Cfquery>

	<cfreturn valuelist(qget.usrid)>--->
	<cfreturn 0>
</cffunction>
--->
<cffunction name="getdata" output="false">
	<cfargument name="type" default="#this.type#">
	<cfargument name="id" default="">
	<cfargument name="lAdditionalFields" default="">
	<cfargument name="whereClause" default="">
	<cfargument name="sortOrder" default="">

	<cfset var qget = "">
	<Cfquery name="qget" >
		select responsesetid, responsesetid as id, form
		<cfif len(arguments.lAdditionalFields)>, #arguments.lAdditionalFields#</cfif>
		from responseset
		where 1=1
		<cfif len (arguments.id) and isnumeric(arguments.id)>
			and responsesetid = #arguments.id#
		</cfif>
		<cfif len(arguments.whereClause)>
			#preservesinglequotes(arguments.whereClause)#
		</cfif>
		<cfif len(arguments.sortOrder)>
			order by #preservesinglequotes(arguments.sortOrder)#
		</cfif>
	</cfquery>
	<cfreturn qget>
</cffunction>
<cffunction name="getResponseSet" output="true">
	<cfargument name="responsesetid">
	<!---<cfargument name="formid">--->

	<Cfset var qget = "">

	<!--- for security sake, we include the form id; perhaps we should check usr permissions --->

	<cfquery name="qget" >
	select responseset.*, responsesetstatus.responsesetstatusname, form.formid, form.formname, usr.usrname 
	from responseset  inner join form on form.formid=responseset.form
	inner join usr on usr.usrid=responseset.usr
	inner join responsesetstatus on responsesetstatus.responsesetstatusid = responseset.responsesetstatus
	where responseset.responsesetid = 
	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
	</cfquery>
	<!---and responseset.form = 
	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
	</cfquery>--->
	
	<cfreturn qget>

</cffunction>
<cffunction name="getResponseSets" output="false">
	<cfargument name="responsesetstatus">
	<cfargument name="usr">
	<cfargument name="form">

	<!--- STUB: this will need optimizing --->
	<cfset var qget = "">

	<cfquery name="qget" >
	select responseset.*, responsesetstatus.responsesetstatusname, form.formid, form.formname, usr.usrname 
	from responseset inner join form on form.formid=responseset.form
	inner join usr on usr.usrid=responseset.usr
	inner join responsesetstatus on responsesetstatus.responsesetstatusid = responseset.responsesetstatus
	where 1=1
	<cfif len(arguments.responsesetstatus)> 
		and responseSetstatus = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetstatus#"> 
	<cfelse>
	<!--- default to responses not completed --->
		and ( responsesetstatus <=4 or responsesetstatus is null )
	</cfif>
	<cfif len(arguments.usr)> and responseset.usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usr#"> 
	</cfif>
	<cfif len(arguments.form)> and responseset.form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.form#"> 
	</cfif>
	order by responsesetstatus, datelastupdated desc
	</cfquery>


	<cfreturn qget>
</cffunction>
<!---<cffunction name="getUsrResponseSets">
	<cfargument name="usr">


	<!--- STUB: this will need optimizing --->
	<cfset var qget = "">

	<cfquery name="qget" >
	select * from responseset where  usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usr#">
	order by responsesetstatus, datelastupdated desc
	</cfquery>

	<cfreturn qget>
</cffunction>--->
<cffunction name="getUsrResponseSetsForForm">
	<cfargument name="usr">
	<cfargument name="form">

	<!--- STUB: this will need optimizing --->
	<cfset var qget = "">

	<cfquery name="qget" >
	select * from responseset where form = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.form#"> and usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usr#">
	order by responsesetstatus, datelastupdated desc
	</cfquery>

	<cfreturn qget>
</cffunction>
<cffunction name="makeActive">
	<cfargument name="responsesetid">
	<cfargument name="formid">

	<!---- this method will move a form response forward in it's workflow, triggering notifications if necessary --->
	<cfset var qChange = "">

	<cfif not isnumeric(arguments.responsesetid) and arguments.responsesetid gt 0>
		Error! Invalid responsesetid<cfabort>
	</cfif>
	<!--- if this is already active, the following update will have no effect, but notices will get re-sent--->
	<cfquery name="qChange" >
	update responseset set responsesetstatus = 2
		where responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
	</cfquery>

	<cfset recordHistory(arguments.responsesetid)>

	<cfset setCurrentOwnerAndNotify(arguments.responsesetid,arguments.formid)>

</cffunction>
<cffunction name="makeComplete">
	<cfargument name="responsesetid">
	<cfargument name="formid">

	<!---- this method will move a form response forward in it's workflow, triggering notifications if necessary --->
	<cfset var qChange = "">

	<cfif not isnumeric(arguments.responsesetid) and arguments.responsesetid gt 0>
		Error! Invalid responsesetid<cfabort>
	</cfif>
	<cfquery name="qChange" >
	update responseset set responsesetstatus = 4, currentassignee = creator
		where responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
	</cfquery>

	<cfset recordHistory(arguments.responsesetid)>
	<!--- send a notice to the creator of this request --->
	<cfinvoke component="#application.modelpath#.noticequeue" responsesetid="#arguments.responsesetid#" method="notifycreatorofcompletion"></cfinvoke>
<!---
	<cfinvoke component="#application.modelpath#.noticequeue" method="cancelNotices" responseset="#arguments.responsesetid#"></cfinvoke>
	<cfset recordHistory(responsesetid=arguments.responsesetid)>
--->
</cffunction>
<cffunction name="makeInactive">
	<cfargument name="responsesetid">

	<cfset var qChange = "">
	<cfset var qClear = "">

	<cfif not isnumeric(arguments.responsesetid) and arguments.responsesetid gt 0>
		Error! Invalid responsesetid<cfabort>
	</cfif>
	<cfquery name="qChange" >
	update responseset set responsesetstatus = 1, currentassignee = creator
		where responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
	</cfquery>
	<cfinvoke component="#application.modelpath#.noticequeue" method="cancelNotices" responseset="#arguments.responsesetid#"></cfinvoke>
	<!---
	<cfset recordHistory(responsesetid=arguments.responsesetid)>
	--->
</cffunction>
<cffunction name="recordHistory">
	<cfargument name="responsesetid">
	<cfset var qget = "">
	<cfset var qinsert = "">

	<cfquery name="qget" >
	select responsesetid, form, usr, responsesetstatus, currentassignee
	
	from responseSet
	where responseset.responsesetid = #arguments.responsesetid# 
	</cfquery>

	<cfquery name="qinsert" >
	insert into responsesethistory ( responsesetid, form, usr, responsesetstatus, currentassignee ) values ( #qget.responsesetid#, #qget.form#, #qget.usr#, #qget.responsesetstatus#, #qget.currentassignee# )
		
	</cfquery>

</cffunction>
<cffunction name="PrintableVersion">
<cfargument name="responsesetid">
<cfargument name="formid">

<cfset var sReturn = "">

<cfinvoke component="#application.modelpath#.form" method="loadData" id="#arguments.formid#" returnvariable="f"></cfinvoke>

<cfif f.formid eq "">
	<em>I'm sorry, I can't find that form.</em>
	<cfabort>
</cfif>

<Cfinvoke component="#application.modelpath#.responseset" method="getResponseSet" responsesetid="#arguments.responsesetid#" formid="#arguments.formid#" returnvariable="qResponseSet"></Cfinvoke>

<cfif qResponseSet.recordcount neq 1>
	<cfdump var="#qresponseset#">
	Error! This is not a valid responsesetid. This record was probably deleted.
	<cfreturn "">
</cfif>

<cfinvoke component="#application.modelpath#.usr" method="getUsr" usrid="#qresponseset.creator#" returnvariable="ThisUsr"></cfinvoke>
<cfinvoke component="#application.modelpath#.object" method="namestring" lastname="#ThisUsr.lastname#" firstname="#ThisUsr.firstname#" returnvariable="ns"></cfinvoke>
<cfif isdate(qresponseset.datelastupdated)>
	<cfset ds = datetimeformat(qResponseSet.datelastupdated,"long")>
<cfelse>
	<cfset ds = datetimeformat(qResponseSet.datecreated,"long")>
</cfif>

<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfinvoke component="#application.modelpath#.form" method="getFormFieldsWithResponses" returnvariable="aFields" formid="#f.formid#" responsesetid="#qResponseSet.responsesetid#"></cfinvoke>
<cfsavecontent variable="sReturn"><cfoutput>
	<p>Saved by #ns# - last updated #ds#</p>
<cfloop from="1" to="#arraylen(aFields)#" index="t">	
	<p>
		<cfif aFields[t].fieldType neq 7>
			<div>
				<strong>#aFields[t].label#</strong>
				<cfif len(aFields[t].fieldcomment)><br />#aFields[t].fieldcomment#</cfif>
			</div>
			<cfinvoke component="#application.modelpath#.formfield" method="getformfieldtargetcolumn" formfieldid="#afields[t].formfieldid#" returnvariable="targetcolumn"></cfinvoke>

			<cfif afields[t].fieldType eq 6> <!--- yes no --->
				<cfinvoke component="#application.modelpath#.yesno" yesnoid="#afields[t].stResponse[targetcolumn]#" returnvariable="sYesNo" method="returnStringValue"></cfinvoke>
				#sYesNo#
			<cfelseif afields[t].optionset eq "">
				#aFields[t].stResponse[targetcolumn]#				
			<cfelse>
				<!--- STUB: this should retrieve from the right column --->
				<cfinvoke component="#application.modelpath#.optionset" method="getoptionvalue" optiondataid="#aFields[t].stResponse[targetcolumn]#" returnvariable="sOptionValue"></cfinvoke>
				#sOptionValue#  <!---Option value--->
			</cfif>
		<br />
		<cfelse>
			<!--- this is an approval step. if it is not satisfied, we halt display of the form here. Because we have to get all the information about a given approval step, we'll just return all the data --->
			<cfif isnumeric(aFields[t].approvalset)>
				<div><strong>#aFields[t].label#</strong>
					<cfif len(aFields[t].fieldcomment)><br />#aFields[t].fieldcomment#</cfif>
				</div>
				<cfloop from="1" to="#arraylen(aFields[t].stApprovalSet.aApprovalData)#" index="a">
					
					<cfinvoke component="#application.modelpath#.approvalset" method="drawReviewField" responsedataid="#aFields[t].stResponse.responsedataid#" fielddata="#aFields[t]#" returnvariable="sApproval" reviewdata="#aFields[t].stReview#" printformat="true"></cfinvoke>
					#sApproval#

				</cfloop>
				<div>
				This review step is <cfif aFields[t].stApprovalSet.satisfied neq true>not</cfif> satisfied.
				</div>
			</cfif>
		</cfif>
	</p>
	</cfloop>
</cfoutput></cfsavecontent>

<cfreturn sReturn>
	</cffunction>
<cffunction name="saveResponseSet">
	<cfargument name="formdata">

	<!--- this function saves/overwrites/updates a set of responses --->

	<cfset var qSave = "">
	<cfset var qInsert = "">

	<!--- this will be algorithmically poor, to start
		STUB: should this record somehow be locked? --->

	<cfif arguments.formdata.responsesetid eq "" or arguments.formdata.responsesetid eq 0>
		<!--- this is a new response, begin by creating a responsesetid --->
		<cfquery name="qInsert"  result="db">
		insert into responseset ( form, usr, creator, currentassignee ) values ( <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.formid#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#session.usr.usrid#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#session.usr.usrid#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#session.usr.usrid#"> )
		</cfquery>
		<!--- db returns insert information, including the new responsesetid --->
		<cfset responsesetid = db.responsesetid>

	<cfelse>
		<cfset responsesetid = arguments.formdata.responsesetid>

		<cfquery name="qUpdate" >
		update responseset set datelastupdated = now();
		</cfquery>

	</cfif>
	<!--- make a backup of this item to keep a history --->
	<cfset recordHistory(responsesetid=responsesetid)>

	<!--- html controls for multiple select items (checkboxes) do not submit anything
		if the user unchecks all the options, or does not check anything.
		To handle this, we must get all of the fields and watch to see what is submitted.
		anything left over we assume has been unchecked. This will also provide the form with some security, 
		where a user with access to one form cannot submit a value for an unconnected form field --->

	<cfinvoke component="#application.modelpath#.form" method="getFormFields" formid="#arguments.formdata.formid#" returnvariable="aFields"></cfinvoke>	
	<cfset lFieldids="">
	<cfset lMultiSelectFieldids = "">
	<cfloop from="1" to="#arraylen(aFields)#" index="i">
		<cfset lFieldids=listappend(lFieldids,aFields[i].formfieldid)>
		<cfif aFields[i].fieldtype eq "5"> <!--- this is a checkbox --->
			<cfset lMultiSelectFieldids = listappend(lMultiSelectFieldids,aFields[i].formfieldid)>
		</cfif>
	</cfloop>

	<cfloop collection="#arguments.formdata#" item="f">

		<!--- form fields are written as type-formfieldid-otherdata --->
		<cfif listlen(f,"-") gte 2>
			<cfset formcontroltype=listfirst(f,"-")>
			<cfset formfieldid=listgetat(f,2,"-")>

			<!--- check the list of valid field ids --->
			<cfif listfind(lFieldids,formfieldid) eq 0>
				<!---<cfset lFieldids=listdeleteat(lFieldids,listfind(lFieldids,formfieldid))>
			<cfelse>--->
				<cfoutput>#formfieldid# #f#</cfoutput>
				
				Error! invalid form field id for this form.<cfabort>
			</cfif>

			<cfswitch expression="#formcontroltype#">
				<cfcase value="f">
					<cfinvoke component="#application.modelpath#.formfield" method="saveFormFieldSubmission" formfieldid="#formfieldid#" responseset="#responsesetid#" value="#arguments.formdata[f]#" ></cfinvoke>
				</cfcase>
				<cfcase value="adhoc">


					<!--- the adhoc approver comes with a set of fields --->
					<cfset sortkey=listgetat(f,3,"-")>
					<cfset approvaldata=listgetat(f,4,"-")>
					<cfset responsedata=listgetat(f,5,"-")>	
					<cfset ahproperty=listlast(f,"-")>	

					<cfif ahproperty eq "email">
						<!--- create a record for saving the formfield submission --->
						<!--- this is necessary if no responsedataid has been created --->
						<cfinvoke component="#application.modelpath#.formfield" method="saveFormFieldSubmission" formfieldid="#formfieldid#" responseset="#responsesetid#" value="#approvaldata#"  returnvariable="rdid"></cfinvoke>
						
						<Cfset stAdhoc = structnew()>
						<cfset stAdhoc.sortkey=sortkey>
						<cfset stAdhoc.approvaldata=approvaldata>
						<cfset stAdhoc.responsedata=rdid>
						<cfset stAdhoc.formfield=formfieldid>
						<Cfset stAdhoc.responseset=arguments.formdata.responsesetid>
						<cfset stAdhoc.firstname = arguments.formdata["adhoc-#formfieldid#-#sortkey#-#approvaldata#-#responsedata#-firstname"]>
						<cfset stAdhoc.lastname = arguments.formdata["adhoc-#formfieldid#-#sortkey#-#approvaldata#-#responsedata#-lastname"]>
						<cfset stAdhoc.department = arguments.formdata["adhoc-#formfieldid#-#sortkey#-#approvaldata#-#responsedata#-department"]>
						<cfset stAdhoc.email = arguments.formdata["adhoc-#formfieldid#-#sortkey#-#approvaldata#-#responsedata#-email"]>
						<cfset stAdhoc.adhocid = arguments.formdata["adhoc-#formfieldid#-#sortkey#-#approvaldata#-#responsedata#-adhocid"]>
						<!--- create a record for saving the adhoc submission --->
						<!---<cfinvoke component="#application.modelpath#.adhoc" method="save" responsedata="#rdid#" responseset="#responsesetid#" value="#arguments.formdata[f]#" sortkey="#sortkey#" formfield="#formfieldid#"approvaldata="#approvaldata#"></cfinvoke>--->
						<cfinvoke component="#application.modelpath#.adhoc" method="save" stdata="#stadhoc#"></cfinvoke>
					</cfif>
				</cfcase>
				<cfcase value="a">
					<cfinvoke component="#application.modelpath#.formfield" method="saveFormFieldSubmission" formfieldid="#formfieldid#" responseset="#responsesetid#" value="0" ></cfinvoke>
				</cfcase>
				<cfcase value="file">
					<!--- handle a file field naming format assumes only one file per field --->
					<cfif len(arguments.formdata[f])> <!--- field is returned as string --->

						<cfinvoke component="#application.modelpath#.fileattachment" method="gettargetpath" formfield="#formfieldid#" responseset="#responsesetid#" returnvariable="targetpath"></cfinvoke>
								
						<cfinvoke component="#application.modelpath#.fileattachment" method="saveAttachment" targetpath="#targetpath#" formfield="#formfieldid#" filefield="#arguments.formdata[f]#" responseset="#responsesetid#" returnvariable="serverfilename"></cfinvoke>

						<!--- form field value should be the string value of the file field
						targetcolumn="f" --->

						<cfinvoke component="#application.modelpath#.formfield" method="saveFormFieldSubmission" formfieldid="#formfieldid#" responseset="#responsesetid#" value="#serverfilename#" ></cfinvoke>
					</cfif>
				</cfcase>
			</cfswitch>
		</cfif>
	</cfloop>
	<!--- having processed all the fields, we can return to process the multi-select fields --->

	<cfloop list="#lMultiSelectFieldids#" index="m"> 
		<cfif structkeyexists(arguments.formdata,"k-#m#")> 
			<!--- this may not be strictly necessary --->
			<cfinvoke component="#application.modelpath#.formfield" method="saveFormFieldSubmission" formfieldid="#m#" responseset="#responsesetid#" value="#arguments.formdata["k-#m#"]#"  returnvariable="rdid"></cfinvoke>

			<cfinvoke component="#application.modelpath#.optiondata" method="setOptionData" formfieldid="#m#" responsesetid="#responsesetid#" responsedataid="#rdid#" selections="#arguments.formdata["k-#m#"]#"></cfinvoke>
		<cfelse>
			<!--- this option clears selections for this field --->
			<cfinvoke component="#application.modelpath#.formfield" method="saveFormFieldSubmission" formfieldid="#m#" responseset="#responsesetid#" value=""  returnvariable="rdid"></cfinvoke>
			<cfinvoke component="#application.modelpath#.optiondata" method="clearOptionData" formfieldid="#m#" responsesetid="#responsesetid#"></cfinvoke>
		</cfif>
	</cfloop>
	<cfreturn responsesetid>

</cffunction>
<cffunction name="setCurrentOwnerAndNotify" ouput="true">
	<cfargument name="responseSetId">
	<cfargument name="formid">
	<cfargument name="debug" default="true">

	<!--- STUB: we may have more IO here than we need --->
	<cfset var qResponseSet = "">
	<Cfset var qFormData = "">

	<!--- get all the responseset data --->
	<cfset qResponseSet = getResponseSet(arguments.responsesetid)>


	<cfif qResponseSet.recordcount eq 0>
		<cfdump var="#arguments#">
		Error! Invalid ResponsesetID <cfabort>
	</cfif>

	<!--- load the form with responses, then find the first unstatisfied workflow and notify it --->
	<cfinvoke component="#application.modelpath#.form" method="getformfieldswithresponses" returnvariable="aFields" formid="#qResponseSet.form#" responsesetid="#arguments.responsesetid#"></cfinvoke>

	<cfif arraylen(aFields) eq 0>
		Error! This form is empty!<cfabort>
	</cfif>
	<cfset reviewPending = false>
	<cfoutput>
		<!--- loop over the fields --->
		<cfloop from="1" to="#arraylen(aFields)#" index="f">
			<!---<cfif arguments.debug>checking form field #aFields[f].fieldtype#</cfif>--->
			<!--- 7 is the review fieldtype --->
			<cfif aFields[f].fieldtype eq 7>
				<cfif arguments.debug>This is an approval step.</cfif>
				<cfif aFields[f].stApprovalSet.satisfied neq true>
					<!--- this review is not satisified --->
					<cfset reviewPending = true>
					<cfif arguments.debug>This review is pending.</cfif>
					<!--- how can we set this currentowner? --->
					<cfinvoke component="#application.modelpath#.noticequeue" approvalset="#aFields[f].approvalset#" responsedata="#aFields[f].stResponse.responsedataid#" method="notifyapprovalset" debug="#arguments.debug#"></cfinvoke>
					<cfif arguments.debug>Breaking loop.</cfif>
					<cfbreak> <!--- exit the loop --->
				</cfif>
			</cfif>		
		</cfloop>
	</cfoutput>
	<!--- we have made it all the way through the form fields- notify the final assignee --->
	<cfif reviewPending eq false>
		<cfinvoke component="#application.modelpath#.noticequeue" responsesetid="#arguments.responsesetid#" method="notifyfinalassignee"></cfinvoke>
		<cfinvoke component="#application.modelpath#.responseSet" responsesetid="#arguments.responsesetid#" method="setOwnerToFinalAssignee"></cfinvoke>
	</cfif>


</cffunction>
<cffunction name="setOwnerToFinalAssignee">
	<cfargument name="responsesetid">

	<Cfset var q1 = "">
	<Cfset var q2 = "">
	<cfset var q3 = "">

	<cfquery name="q1" >
	select form from responseset where responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
	</cfquery>
	<cfif q1.recordcount>
		<cfquery name="q2" >
		select finalassignee from form where formid = #q1.form#
		</cfquery>
		<Cfif q2.recordcount>
			<cfif q2.finalassignee eq 0>
				<!--- the default is to clomplete the request --->
				<cfquery name="q3" >
				update responseset set currentassignee = #q2.finalassignee#, responsesetstatus = 4 where responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
				</cfquery>
			<cfelse>
				<cfquery name="q3" >
				update responseset set currentassignee = #q2.finalassignee#, responsesetstatus = 3 where responsesetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
				</cfquery>
			</cfif>
		<cfelse>
			Error! form has invalid final assignee!<cfabort>
		</Cfif>
	</cfif>
</cffunction>
<cffunction name="submissionList" output="true">

		<cfargument name="responseset">
		<!---<cfargument name="formid" default="#url.formid#">--->

		<cfset var sReturn = "">

		<cfsavecontent variable="sReturn"><cfoutput>
			<ol>
				<cfloop query="arguments.ResponseSet">
					<li><a href="form.cfm?formid=#arguments.ResponseSet.form#&responsesetid=#arguments.ResponseSet.responsesetid#"> 
						#arguments.responseset.formname#
						<em>#arguments.responseset.usrname#</em>
						<strong>#arguments.ResponseSet.responsesetstatusname#</strong>
						#dateformat(arguments.responseSet.datecreated,"mm/dd/yy")# 
						#timeformat(arguments.responseSet.datecreated,"hh:mm tt")#
						<cfif arguments.responseset.datelastupdated neq "">last updated #arguments.ResponseSet.datelastupdated#</cfif></a>
						<cfif session.usr.accesslevel lt 3 or (session.usr.accesslevel eq 3 and arguments.responseset.creator eq session.usr.usrid)>
							<a href="#cgi.SCRIPT_NAME#?responsesetid=#arguments.responseset.responsesetid#&action=delete&type=responseset&formid=#arguments.responseset.form#" onclick="return confirm('Are you sure you want to delete this response?');">[ Delete ]</a>
						</cfif>
						<a target="_blank" href="formaspdf.cfm?formid=#arguments.responseset.form#&responsesetid=#arguments.responseset.responsesetid#">[ Download ]</a>
					</li>
				</cfloop>
				</ol>
			</cfoutput>
		</cfsavecontent>

		<cfreturn sReturn>
	</cffunction>
<cffunction name="submissionTable" output="false">

		<cfargument name="responseset">
		<!---<cfargument name="formid" default="#url.formid#">--->

		<cfset var sReturn = "">

		<cfsavecontent variable="sReturn"><cfoutput>
			<table>
				<thead>
				<tr>
					<cfloop list="#arguments.responseset.columnlist#" index="x">
						<th>#x#</th>
					</cfloop>
				</tr>
			</thead>
			<tbody>
				<cfloop query="arguments.ResponseSet">
					<tr>
						<cfloop list="#arguments.responseset.columnlist#" index="x">
							<cfif left(x,4) neq "date">
								<td>#arguments.responseset[x]#</td>
							<cfelse>
								<cfif isvalid("date",arguments.responseset[x])>
									<td>#dateformat(arguments.responseset[x],"medium")#</td>
								<cfelse>
									<td>#arguments.responseset[x]#</td>
								</cfif>
							</cfif>
						</cfloop>
					</tr>
				</cfloop>
					
			</tbody>
			</table>
			</cfoutput>
		</cfsavecontent>

		<cfreturn sReturn>
	</cffunction>
</cfcomponent>
