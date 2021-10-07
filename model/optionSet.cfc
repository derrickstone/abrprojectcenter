<cfcomponent extends="object">
<cfset this.type="optionSet">
<cffunction name="delete" hint="extends delete to also remove related options">
		<cfargument name="type" type="String">
		<cfargument name="id" type="numeric">

		<cfset var qDel1 = "">
		<cfset var qDelete = "">
		<!--- check access level --->
		<cfif session.usr.accesslevel eq 1>
			<!--- STUB: maybe a good place for cftransaction? --->
			<cfquery name="qDel1" >
			delete from optiondata where optionset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>

			<cfquery name="qDelete" >
			delete from optionset where optionsetid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			
			<cfreturn "Deleted.">
			
		<cfelse>
			<Cfreturn "Insufficient privileges">
		</cfif>
		
		</cffunction>
<cffunction name="getOptions">
	<cfargument name="optionsetid">
	<cfset var qget = "">

	<cfquery name="qget" >
	select optiondataid, optiondataid as id, optiondataname, optiondataname as name from optiondata where optionset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.optionsetid#">
		order by sortkey
	</cfquery>
	<cfreturn qget>
</cffunction>
<cffunction name="getOptionValue">
	<cfargument name="optiondataid">

	<Cfset var qget = "">

	<cfquery name="qget" >
	select optiondataname from optiondata where optiondataid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.optiondataid#">
	</cfquery>
	<cfif qget.recordcount>
		<cfreturn qget.optiondataname>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>
<cffunction name="getSets">
	<cfargument name="usr" >

	<cfset var qget = "">

	<!--- stub: we should add somethin for the organization here 
	<cfquery name="qget" >
	select optionsetid, optionsetname from set where 
	creator = #arguments.usr#
	</cfquery> --->
	<cfinvoke component="#application.modelpath#.object" method="getData" type="optionset" returnvariable="qget"></cfinvoke>

	<cfreturn qget>
	</cffunction>
<cffunction name="handleEditForm">
	<cfargument name="formdata">

	<cfset var qClear = "">
	<Cfset var qsave = "">
	<cfset var optionCounter = 0>
	<cfset var lAdded = "">
	<!--- think about this... will we lose user responses if we overwrite previous values? --->
	<cfquery name="qClear" >
	delete from optiondata where optionset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.optionsetid#">
	</cfquery>
	
	<cfloop list="#arguments.formdata.setData#" index="od" delimiters="#chr(13)##chr(10)#">
		<!--- only add unique elements --->
		<cfif listfindnocase(lAdded,od) eq "no">
			<cfquery name="qsave" >
			insert into optiondata ( optiondataname, creator, optionset, sortkey ) values ( <cfqueryparam value="#od#" cfsqltype="cf_sql_varchar">, <cfqueryparam cfsqltype="cf_sql_integer" value="#session.usr.usrid#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.optionsetid#">, <cfqueryparam cfsqltype="cf_sql_integer" value="#optionCounter#">)
			</cfquery>

			<cfset optionCounter = optionCounter+1>
			<cfset lAdded = listAppend(lAdded,od)>

		</cfif>
	</cfloop>
	<cfreturn "#optionCounter# items added">
</cffunction>

</cfcomponent>