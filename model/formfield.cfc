<cfcomponent extends="object">
<cfset this.type="formfield">
<cffunction name="delete">
	<cfargument name="id">
<!--- remove the form field and any related data --->
	<Cfset var qDelete1 = "">
	<Cfset var qDelete2 = "">
	<Cfset var qDelete3 = "">
	<Cfset var qDelete4 = "">
	<Cfset var qDelete5 = "">
	<cfset var qget1 = "">
	<cfset var qget2 = "">
	<cfset var qshift = "">

	<cfif not isnumeric(arguments.id)>
		Error! Invalid formfieldid to delete.<cfabort>
	</cfif>
	

	<cfquery name="qDelete1" datasource="#application.dsn#">
	delete from adhoc where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qDelete2" datasource="#application.dsn#">
	delete from review where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qget1" datasource="#application.dsn#">
	select * from fileattachment where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<!--- loop over files and delete them --->
	<cfloop query="qget1">
			<!--- STUB: to do --->
	</cfloop>

	<cfquery name="qDelete3" datasource="#application.dsn#">
	delete from fileattachment where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qDelete4" datasource="#application.dsn#">
	delete from responsedata where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qget2" datasource="#application.dsn#">
	select form, sortkey from formfield where formfieldid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfquery name="qDelete5" datasource="#application.dsn#">
	delete from formfield where formfieldid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
	</cfquery>
	<cfif isnumeric(qget2.sortkey)>
		<cfquery name="qshift" datasource="#application.dsn#">
		update formfield set sortkey = sortkey-1 where form = #qget2.form# and sortkey > #qget2.sortkey#
		</cfquery>
	</cfif>
</cffunction>
<cffunction name="getFieldTypeFromId">
	<cfargument name="formfieldtypeid">

	<cfset var qget="">

	<!--- cache this --->

	<cfif structkeyexists(application,"stFieldType") eq false or url.reset eq 1>
		<cflock scope="application" timeout="10" type="exclusive">
			<cfset application.stFieldType = structnew()>
		</cflock>
	</cfif>
	<cfif structkeyexists(application.stFieldType,arguments.formfieldtypeid)>
		<cfset sReturn = application.stFieldType[arguments.formfieldtypeid]>
	<cfelse>

		<cfquery name="qget" datasource="#application.dsn#">
		select component from formfieldtype where formfieldtypeid =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfieldtypeid#">
		</cfquery>
		<cflock scope="application" timeout="10" type="exclusive">
			<cfset application.stFieldType[arguments.formfieldtypeid] = qget.component>
		</cflock>
		<cfset sReturn = qget.component>
	</cfif>
	<cfreturn sReturn>
</cffunction>

<cffunction name="getdefaulttargetcolumn">
	<cfargument name="formfieldtypeid">

	<cfset var qget = "">

	<cfquery name="qget" datasource="#application.dsn#">
	select responsedatacolumn from formfieldtype where formfieldtypeid = #arguments.formfieldtypeid#
	</cfquery>

	<cfreturn qget.responsedatacolumn>

	</cffunction>

<cffunction name="getFormFieldTargetColumn">
	<cfargument name="formfieldid">

	<cfset var returnvalue = "">

	<!--- STUB: cache this heavily... later we need to update this cache if the form is edited --->

	<cfset var qget = "">
	<!--- initialize the cache structure if it does not exist --->
	<cfif not structkeyexists(application,"stTargetColumn") or url.reset eq 1>
		<cflock scope="Application" type="exclusive" timeout="10">
			<cfset application.stTargetColumn = structnew()>
		</cflock>
	</cfif>

	<cfif structkeyexists(application.stTargetColumn,arguments.formfieldid) eq true>
		<cfset returnValue = application.stTargetColumn[arguments.formfieldid]>
	<cfelse>
		<cfquery name="qget" datasource="#application.dsn#">
		select targetcolumn from formfield where formfieldid = #arguments.formfieldid#
		</cfquery>

		<cflock scope="Application" type="exclusive" timeout="10">
			<cfset application.stTargetColumn[arguments.formfieldid] = qget.targetcolumn>
		</cflock>
		<cfset returnValue = qget.targetcolumn>
	</cfif>

	<cfif returnValue eq ""> 
		<cfset returnValue = "stringresponse">
	</cfif>

	<cfreturn returnValue>
</cffunction>
<cffunction name="saveFormFieldSubmission">

	<cfargument name="formfieldid">
	<!---<cfargument name="targetcolumn">--->
	<cfargument name="value">
	<cfargument name="responseset">

	<cfset var qSave = "">
	<cfset var qCheck = "">

	<!---
	<cfswitch expression="#arguments.targetcolumn#">
		<cfcase value="n">
			<cfset t = "numericresponse">
		</cfcase>
		<cfcase value="t">
			<cfset t ="textresponse">
		</cfcase>
		<cfcase value="f">
			<cfset t = "filepath">
		</cfcase>

		<cfdefaultcase> <!--- case s --->
			<cfset t = "stringresponse">
		</cfdefaultcase>
	</cfswitch>
--->
	<cfset targetcolumn=getFormFieldTargetColumn(arguments.formfieldid)>

<!--- check to see if this response exists, and if it needs to be updated --->


	<cfif isnumeric(arguments.responseset) and arguments.responseset neq 0>
		<cfquery name="qcheck" datasource="#application.dsn#">
		select * from responsedata where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.formfieldid)#">
		and responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.responseset)#">
		</cfquery>

		<cfif qcheck.recordcount eq 0>	<!--- insert --->
			<cfset iReturn = saveResponseData(arguments.formfieldid,arguments.responseset,targetcolumn,arguments.value)>
		<cfelse>
			<!--- update --->
			<!--- for the sake of performance, we'll use an if statement rather than evaluate --->
			<cfset ischanged = false>
			
			<cfif evaluate("qcheck.#targetcolumn#") neq arguments.value>
				<cfset ischanged = true>
			</cfif>
			
			<cfif (ischanged)>
				<cfquery name="qSave" datasource="#application.dsn#">
				update responsedata set #targetcolumn# = 
				<cfswitch expression="#targetcolumn#">
					<cfcase value="stringresponse">
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.value#">
					</cfcase>
					<cfcase value="numericresponse">
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.value#">
					</cfcase>
					<cfcase value="dateresponse">
						<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(arguments.value)#">
					</cfcase>
					<cfcase value="approval">
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.value#">
					</cfcase>
					<cfdefaultcase>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.value#">
					</cfdefaultcase>
				</cfswitch>
					where 
					responsedataid = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(qcheck.responsedataid)#">
				</cfquery>
			</cfif>
			<cfset iReturn = qcheck.responsedataid>
		</cfif>
	<cfelse>
		<cfset iReturn = saveResponseData(arguments.formfieldid,arguments.responseset,targetcolumn,arguments.value)>
		

	</cfif>
	<cfreturn iReturn>
</cffunction>
<cffunction name="saveResponseData">
	<cfargument name="formfieldid">
	<cfargument name="responseset">
	<cfargument name="targetcolumn">
	<cfargument name="value">
	
	<cfset var db = "">
	<cfset var qsave = "">

	<!--- kind of not cohesive to have this save here --->
	<cfquery name="qSave" datasource="#application.dsn#" result="db">
		insert into responsedata (  formfield, responseset, #arguments.targetcolumn#, creator ) values (
			
			<cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.formfieldid)#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.responseset)#">,
			<cfswitch expression="#targetcolumn#">
					<cfcase value="stringresponse">
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.value#">,
					</cfcase>
					<cfcase value="numericresponse">
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.value#">,
					</cfcase>
					<cfcase value="dateresponse">
						<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(arguments.value)#">,
					</cfcase>
					<cfcase value="approval">
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#int(arguments.value)#">,
					</cfcase>
					<cfdefaultcase>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.value#">,
					</cfdefaultcase>
				</cfswitch>
			<cfqueryparam cfsqltype="cf_sql_integer" value="#int(session.usr.usrid)#"> )
		</cfquery>

	<cfreturn db.responsedataid>
	</cffunction>
</cfcomponent>
