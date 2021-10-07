<cfcomponent extends="object">
	<cffunction name="clearOptionData">
	<cfargument name="formfieldid">
	<cfargument name="optionset">
	<cfargument name="responsesetid">

	<Cfset var qDel = "">

	<cfquery name="qDel" >
		delete from keyoptiondata
		where  formfieldid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfieldid#"> 
		and responseset =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
	</cfquery>

</cffunction>
<cffunction name="getData">
	<cfargument name="optionsetid">

	<Cfset var qget = "">

	<cfquery name="qget" >
		select optiondataid, optiondataid as id, optiondataname, optiondataname as value, optiondataname as name, sortkey from optiondata
		where optionset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.optionsetid#">
	</cfquery>
	<cfreturn qget>
</cffunction>
<cffunction name="getMembers">
	<cfargument name="optiondata">
	<cfset var qget = "">

	<cfquery name="qget" >
	select keyusroptiondata.usr, usr.usrid, usr.firstname, usr.lastname, usr.email
	from keyusroptiondata inner join usr on usr.usrid=keyusroptiondata.usr
	where keyusroptiondata.optiondata = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.optiondata#">
	</cfquery>
	<cfreturn qget>
</cffunction>


<cffunction name="getOptionData" hint="This method gets previously clicked selections">
	<cfargument name="formfieldid">
	<cfargument name="responsesetid">
	<cfargument name="responsedataid">
	<cfargument name="sortOrder" default="">

	<cfset var qget = "">
<!--- hmmm - the optionset value may not be required --->
	<cfquery name="qget" >
	select value from keyOptionData where formfieldid  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfieldid#">
	and responseset  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">
	and responsedata  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">
	<Cfif len(arguments.sortOrder)> 
	order by #arguments.sortOrder#
	</Cfif>
	</cfquery>

	<cfreturn valuelist(qget.value)>
</cffunction>
<cffunction name="getUsrRelations">
	<Cfargument name="usr">

	<cfset var qget = "">

	<Cfquery name="qget" >
	select optiondata from keyusroptiondata where usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usr#">
	</Cfquery>

	<cfreturn qget>
</cffunction>
<cffunction name="getValidUsrOptionDataRelations">

	<cfset var qget = "">

	<cfquery name="qget" >
	select concat(optionset.optionsetname,'-',optiondata.optiondataname) as name, optiondata.optiondataid as id from optiondata inner join keyusroptiondata on optiondata.optiondataid = keyusroptiondata.optiondata inner join optionset on optiondata.optionset = optionset.optionsetid
	order by optiondataname

	</cfquery>

	<cfreturn qget>
</cffunction>
<cffunction name="setOptionData">
	<cfargument name="formfieldid">
	<cfargument name="responsesetid">
	<cfargument name="responsedataid">
	<cfargument name="selections">

	<Cfset var qadd = "">
	<cfset var qdel = "">

	<cfset clearOptionData(formfieldid=arguments.formfieldid,responsesetid=arguments.responsesetid)>

	<cfloop list="#arguments.selections#" index="s">
		<cfquery name="qadd" >
		insert into keyoptiondata ( formfieldid, responseset, responsedata, value ) values (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formfieldid#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsesetid#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.responsedataid#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#s#">
			)
		</cfquery>
	</cfloop>



</cffunction>
</cfcomponent>