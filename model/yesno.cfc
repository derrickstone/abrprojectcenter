<cfcomponent>
<cfset this.type = "yesno">
	<cffunction name="returnStringValue">
		<cfargument name="yesnoid">
		<Cfset var qget = "">

		<!--- STUB: this should, at a minimum, be cached --->

		<Cfquery name="qget" >
		select yesnoname from yesno where yesnoid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.yesnoid#">
		</cfquery>

		<cfreturn qget.yesnoname>
		</cffunction>
</cfcomponent>