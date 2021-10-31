<cfcomponent>
	<cffunction name="search">
		<cfargument name="options">

		<cfset var qget = "">
		<cfset var qBuild = "">
		<cfset var sKeywordConstraint = "">

		<cfset qBuild = querynew("id,name,type")>



		<!--- some day we may want to get more sophisticated --->
		
		
		

		<cfif structkeyexists(arguments.options,"type") and len(arguments.options.type)>
			<cfloop list="#arguments.options.type#" item="t">
				<cfquery name="qGet">
					select #t#id as id, #t#name as name from #t# 
					<cfif structkeyexists(arguments.options,"keyword") and len(arguments.options.keyword)>
					inner join keykeyword#t# on keykeyword#t#id = #t#
					</cfif>
					where 1=1
					<!--- STUB: add searchable fields --->
					<cfif structkeyexists(arguments.options,"searchstring") and len(arguments.options.searchstring)>
					and #t#name like '%#arguments.options.searchstring#%'
					</cfif>
					<cfif structkeyexists(arguments.options,"keyword") and len(arguments.options.keyword)>
					and keykeyword#t#.keywordid in  ( #arguments.options.keyword# )
					</cfif>
				</cfquery>	
				<cfif qget.recordcount gt 0>
					<cfloop query="qget">
						<cfset queryAddRow(qBuild,1)>
						<cfset qbuild.id=qget.id>
						<cfset qbuild.name=qget.name>
						<cfset qbuild.type=t>
					</cfloop>
				</cfif>
			</cfloop>

		</cfif>
		<cfreturn qBuild>
	</cffunction>

</cfcomponent>