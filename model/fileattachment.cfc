<cfcomponent extends="object">
<cfset this.type="fileattachment">
<cffunction name="getAttachmentForFormfield">
<cfargument name="formfield">
<cfargument name="responseset">

<cfset var qget = "">

	<cfquery name="qget" >
		select filepath from responsedata where formfield = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfield#"> and responseset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responseset#">
	</cfquery>
	<!---<cfdump var="#qget#">--->
	<cfreturn qget>
</cffunction>
<cffunction name="gettargetpath">
	<cfargument name="formfield">
	<cfargument name="responseset">

	<cfset var targetpath=application.rootpath & "/">

	<cfset leadingfolder = int(arguments.formfield / 1000)><!--- int is the smallest integer, which should be 0 for the first 1000 items; this grouping by folder will protect against file system limitations --->
	<cfif leadingfolder neq 0>
		<cfset targetpath = targetpath & application.filestoragepath & "/" & leadingfolder & "/" & arguments.formfield>
	<cfelse>
		<cfset targetpath = targetpath & application.filestoragepath & "/" & arguments.formfield>
	</cfif>
	<cfset targetpath = targetpath & "/" & arguments.responseset>

	<cfreturn targetpath>
	</cffunction>
	<cffunction name="geturl">
	<cfargument name="formfield">
	<cfargument name="responseset">

	<cfset var targetpath="/">

	<cfset leadingfolder = int(arguments.formfield / 1000)><!--- int is the smallest integer, which should be 0 for the first 1000 items; this grouping by folder will protect against file system limitations --->
	<cfif leadingfolder neq 0>
		<cfset targetpath = targetpath & application.filestoragepath & "/" & leadingfolder & "/" & arguments.formfield>
	<cfelse>
		<cfset targetpath = targetpath & application.filestoragepath & "/" & arguments.formfield>
	</cfif>
	<cfset targetpath = targetpath & "/" & arguments.responseset>

	<cfreturn targetpath>
	</cffunction>
	<cffunction name="saveattachment">
		<cfargument name="formfield">
		<cfargument name="targetpath">
		<cfargument name="filefield">
		<cfargument name="responseset">

		<cfset var qCheck = "">
		<!--- to prevent orphaned files, check to make sure a file doesn't already exist --->
						
		<cfinvoke component="#application.modelpath#.fileattachment" method="getAttachmentForFormField" formfield="#arguments.formfield#" responseset="#arguments.responseset#" returnvariable="qCheck"></cfinvoke>


		<cfif qcheck.recordcount>
			<!--- delete the file --->
			<cfset fullpath = arguments.targetpath&"/"&qcheck.filepath>
			<cfif fileexists(fullpath)>
				<cflock name="#arguments.targetpath#" type="exclusive" timeout="10">
					<cffile action="delete" file="#fullpath#">
				</cflock>
			</cfif>
			<!--- remove the record --->
		<!--- Should no longer be required	
		<cfquery name="qcheck" >
			delete from fileattachment where fileattachmentid = <cfqueryparam cfsqltype="cf_sql_integer" value="#qcheck.fileattachmentid#"> 
			</cfquery> --->

		</cfif>
		<!--- check to make sure the destination folder exists --->
		<cfif directoryexists(arguments.targetpath) eq false>
			<cflock name="#arguments.targetpath#" type="exclusive" timeout="10">
				<cfdirectory action="create" directory="#arguments.targetpath#">
			</cflock>
		</cfif>
		<cflock name="#arguments.targetpath#" type="exclusive" timeout="10">
			<cffile action="upload" destination="#arguments.targetpath#" filefield="#arguments.filefield#" nameconflict="overwrite">
		</cflock>
		<!---<cfquery name="qFileInsert" >
		insert into fileattachment ( filepath, creator, formfield, originalfilename, responseset ) values (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cffile.serverfile#">, 							 
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.usr.usrid#">, 
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfield#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cffile.clientfile#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responseset#">
			)
		</cfquery> ---><!--- not sure I have the form field value --->
		<cfreturn cffile.serverfile>

	</cffunction>
</cfcomponent>