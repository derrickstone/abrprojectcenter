<cfcomponent extends="object" output="false">
	<cfset this.type="adhoc">
<cffunction name="checkAuthorization" output="false">
	<cfargument name="authorizer">
	<cfargument name="responsedata">
	<cfargument name="approvaldata">

	<!--- making the assumption these three fields will suffice --->
	<Cfset var qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
		select reviewid from review where responsetype = 1 and usr = #arguments.authorizer#
		and responsedata = #arguments.responsedata# and approvaldata = #arguments.approvaldata#
	</cfquery>

	<cfreturn qget.recordcount>

</cffunction>
<cffunction name="drawAdHocControl">
	<cfargument name="recorddata">
	<cfargument name="reviewdata">
	<cfargument name="responsedataid">
	<cfargument name="sortkey">
	<cfargument name="responsesetstatus">
	<Cfargument name="required" default="false">

	<cfset var sReturn = "">

	<cfset au = arguments.recorddata>
			
	<cfset thisnameprefix="adhoc-#arguments.recorddata.formfield#-#arguments.sortkey#-#arguments.recorddata.approvaldata#-#arguments.responsedataid#">
	<cfset sReturn = sReturn & "<div>"> <!---#namestring(au.lastname,au.firstname)#">--->
	<cfif au.adhocid eq "" or au.adhocid eq 0><cfset au.adhocid = -1></cfif>
	<cfset sReturn = sReturn & '<input type="hidden" name="#thisnameprefix#-adhocid" value="#au.adhocid#">'>	

	<cfset sReturn = sReturn & '<input type="text" class="adhoc" name="#thisnameprefix#-firstname" value="#au.firstname#"  placeholder="Enter a first name." '>
	<cfif  arguments.required eq true>
		<cfset sReturn = sReturn & " required " >
	</cfif>
	<cfset sReturn = sReturn & ' maxlength="255" >'>
	<cfset sReturn = sReturn & '<input type="text" class="adhoc" name="#thisnameprefix#-lastname" value="#au.lastname#"  placeholder="Enter a last name." '>
	<cfif  arguments.required eq true>
		<cfset sReturn = sReturn & " required " >
	</cfif>
		
	<cfset sReturn = sReturn & ' maxlength="255" >'>

	<cfset sReturn = sReturn & '<input type="text" class="adhoc" name="#thisnameprefix#-department" value="#au.department#"  placeholder="Enter the department or company affiliation." '>
	<cfif  arguments.required eq true>
		<cfset sReturn = sReturn & " required " >
	</cfif>
	
	<cfset sReturn = sReturn & ' maxlength="255" >'>

	<cfset sReturn = sReturn & '<input type="email" class="adhoc" name="#thisnameprefix#-email" value="#au.email#"  placeholder="Enter a valid email address." '>
	<cfif arguments.required eq true>
		<cfset sReturn = sReturn & " required " >
	</cfif>
	
	<cfset sReturn = sReturn & ' maxlength="255" >'>

	<cfset sReturn = sReturn & " <em>">
	<cfif structkeyexists(arguments.reviewdata,au.usr)>
		<cfif arguments.reviewdata[au.usr].responsetype eq 1>			
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

	<cfreturn sReturn>
</cffunction>
<cffunction name="getadhocarray" output="false">

	<cfargument name="formfield">
	<cfargument name="responseset" default="">
	<cfargument name="adhocnumber">
	<cfset var qget = "">
	<cfset var aReturn = arraynew(1)>

	<cfquery name="qget" datasource="#application.dsn#">
	select adhoc.*, review.responsetype from adhoc left outer join review on review.reviewid = adhoc.review
	where 
		<cfif isnumeric(arguments.responseset)>
			adhoc.formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfield#">
		and adhoc.responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responseset#">
		<cfelse>
			0 = 1
		</cfif>
	</cfquery>
	<!--- create a struct template --->
	<cfset stTemp = structnew()>#
	<cfloop list="#qget.columnlist#" index="f">
		<cfset stTemp[f]="">
	</cfloop>
	<!--- convert any existing data into an array --->
	<cfset aReturn = queryToArrayOfStructs(qget)>
	<!--- make sure our array is fully-sized by appending empty structs --->
	<cfif arguments.adhocnumber neq "">
		<cfloop from="1" to="#arguments.adhocnumber#" index="g">
			<cfif g gt arraylen(aReturn)>
				<cfset arrayappend(aReturn,stTemp)>
			</cfif>
		</cfloop>
	</cfif>

	<cfreturn aReturn>

</cffunction>
<cffunction name="getdata" output="true">
	<cfargument name="id">
	<cfset var qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
		select adhocid as id, adhocname as name, adhoc.*, form.formid from adhoc
		inner join formfield on formfield.formfieldid = adhoc.formfield
		inner join form on formfield.form = form.formid
		where adhocid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<Cfreturn qget>
</Cffunction>
<cffunction name="getformid" output="false">
	<cfargument name="adhocid">
	<cfset var qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
		select formfield.form from formfield inner join adhoc on adhoc.formfield = formfield.formfieldid
		where adhocid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.adhocid#">
	</cfquery>
	<Cfreturn qget.form>
</Cffunction>
<cffunction name="getmembers" output="false"> 
	<cfargument name="responsedata">
	<cfargument name="approvaldata">
	<cfargument name="membercount" default="">

	<cfset var qget = "">
	<cfset var x = "">
	<cfset var qtrued = "">

	<cfif arguments.responsedata eq "">
		<cfset arguments.responsedata = 0>
	</cfif>

	<cfquery name="qget" datasource="#application.dsn#">
	select adhoc.*, usr.firstname, usr.lastname, usr.email, usr.department, responsetype.responsetypename
	from adhoc left outer join usr on usr.usrid = adhoc.usr left outer join responsetype on responsetype.responsetypeid = adhoc.responsetype
	where adhoc.responsedata = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.responsedata)#"> 
	and adhoc.approvaldata =  <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.approvaldata)#"> 
	order by adhoc.sortkey
	</cfquery>
	<!---<cfdump var="#qget#">--->

	<cfif arguments.membercount eq "">
		<cfreturn qget>
	</cfif>

	<!--- true up the recordcount to the maximum number of members --->
	<Cfset qtrued = querynew(qget.columnlist)>
	<cfloop query="qget">
		<cfset queryaddrow(qtrued)>
		<Cfloop list="#qget.columnlist#" index="c">
			<Cfset querysetcell(qtrued,c,qget[c])>
		</cfloop>
	</Cfloop>

	<cfif qget.recordcount lt (arguments.membercount)> <!--- starting from a possible 0 --->
		<cfloop from="#qget.recordcount#" to="#(arguments.membercount-1)#" index="x">
		<cfset queryaddrow(qtrued)>
		<cfset querysetcell(qtrued,"adhocid",0)>
		</cfloop>
	</cfif>

	<cfreturn qtrued>

</cffunction>
<!---<cffunction name="drawFormControl">
	<cfargument name="aAdHoc">
	<cfargument name="formfield">


	<cfset var sReturn = "">
	<cfset var qResponse = "">
	<cfset var stResponse = structnew()>

	<!--- create a cached data type for response types --->
	<cfquery name="qResponse" datasource="#application.dsn#">
	select * from responsetype
	</cfquery>
	<cfloop query="qResponse">
		<cfset stResponse[qResponse.responsetypeid]=qResponse.responsetypename>
	</cfloop>

	<cfset actualreviewers = 0>
	<cfset satisfied = 0>
	<cfsavecontent variable="sReturn"><cfoutput>
		<cfloop from="1" to="#arraylen(arguments.aAdhoc)#" index="q">
			Reviewer #q# email<input type="text" name="adhoc-#q#-#arguments.formfield#" value="#arguments.aAdHoc[q].email#"> 
			<cfif len(arguments.aAdHoc[q].email) and isvalid("email",arguments.aAdHoc[q].email)>
				<cfset actualreviewers=actualreviewers+1>
			</cfif>
			<cfif isnumeric(arguments.aAdHoc[q].responsedata) and structkeyexists(stResponse,arguments.aAdHoc[q].responsedata)>
				(#stResponse[arguments.aAdHoc[q].responsedata]#)
				<cfif aAdHoc[q].responsedata eq 1>
					<cfset satisfied = satisfied+1>
				</cfif>arguments.aAdHoc[q].email
			<cfelse>
				<em>no review</em>
				</cfif>
				<cfif session.usr.accesslevel lte 2 OR session.usr.usrid eq arguments.aAdHoc[q].usr>
			<a href="reviewadhoc.cfm?adhocid=#arguments.aAdHoc[q].adhocid#">[ Review ]</a>
		</cfif>
				<br />
		</cfloop>
		This Ad Hoc review is <cfif satisfied neq actualreviewers> not</cfif> satisfied.
	</cfoutput></cfsavecontent>
	<cfreturn sReturn>
</cffunction>--->

<cffunction name="save" output="false">
	<cfargument name="stdata">
	<!---<cfargument name="responsedata">
	<cfargument name="responseset">
	<cfargument name="formfield">
	<cfargument name="value">
	<cfargument name="sortkey">
	<cfargument name="approvaldata">--->
	

	<cfset var qsave="">
	<cfset var qcheck="">
	<cfset var qUsr = "">
	<cfset var qInsert = "">

	<!--- STUB: handle blank emails --->
	<cfif arguments.stdata.email eq "">
		<Cfset usrid = 0>
	<cfelse>
		<cfquery name="qUsr" datasource="#application.dsn#">
		select usrid from usr where email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.email#">
		</cfquery>
		<!--- if needed, create a user account to let this person log in --->
		<cfif qUsr.recordcount eq 0>
			<!--- create this user, making sure the usrname is unique --->
			<cfset newusrname="#arguments.stdata.firstname##arguments.stdata.lastname#">
			<cfquery name="qcheck" datasource="#application.dsn#">
			select usrid from usr where usrname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newusrname#">
			</cfquery>
			<cfset incr = 1>
			<cfloop condition="#qcheck.recordcount# gt 0">
				<cfset incr = incr+1>
				<cfset newusrname = newusrname&incr>
				<cfquery name="qcheck" datasource="#application.dsn#">
				select usrid from usr where usrname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newusrname#">
				</cfquery>
			</cfloop>
			

			<cfquery name="qInsert" datasource="#application.dsn#" result="db">
			insert into usr ( email, firstname, lastname, department, accesslevel, usrname ) values 
				( <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.email#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.firstname#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.lastname#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.department#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="4">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#newusrname#">)
			</cfquery>
			<cfset usrid = db.usrid>
		<cfelse>
			<cfset usrid = qUsr.usrid>
		</cfif>
	</Cfif>



	<cfif arguments.stdata.adhocid eq 0 or arguments.stdata.adhocid eq -1>
		
		<cfquery name="qSave" datasource="#application.dsn#">
		insert into adhoc ( sortkey, usr, responsedata, responseset, formfield, approvaldata, creator, firstname, lastname, department, email ) values 
			( <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.sortkey#">,
			  <cfqueryparam cfsqltype="cf_sql_integer" value="#usrid#">,
			  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.responsedata#">,
			  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.responseset#">,
			  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.formfield#">,
			  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.approvaldata#">,
			  <cfqueryparam cfsqltype="cf_sql_integer" value="#session.usr.usrid#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.firstname#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.lastname#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.department#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.email#">
				)
		</cfquery>
	<cfelse>
		<cfquery name="qSave" datasource="#application.dsn#">
		update adhoc set 
			usr=  <cfqueryparam cfsqltype="cf_sql_integer" value="#usrid#">,
			firstname =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.firstname#">,
			lastname =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.lastname#">,
			department =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.department#">,
			email =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stdata.email#">,
			datelastupdated=now()
			where
			responsedata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.responsedata#">
			and 
			responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.responseset#">
			and sortkey = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.sortkey#">
			and approvaldata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stdata.approvaldata#">
		</cfquery>
	</cfif>
	<cfreturn "Saved">
</cffunction>
</cfcomponent>