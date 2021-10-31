<cfcomponent >
	
	<cffunction name="configureForm" output="true">
	<cfargument name="formdata">
	<cfargument name="type" default="#this.type#">
	<cfargument name="id">
	
	<cfset var sReturn = "">
	<cfset var sFilePath = "../"&application.viewpath&"/"&arguments.type&"ConfigureForm.cfm">
	<cfset var o = "">

	<cfset o =loadData(type=arguments.type,id=arguments.id)>
	
	<cfif fileexists(sFilePath)>
		<cfsavecontent variable="sReturn"><cfoutput>
		<cfinclude template="#sFilePath#">
		</cfoutput></cfsavecontent>
	<cfelse>
		<cfset sReturn = "I'm sorry, a configuration form does not exist for this type.">
	</cfif>
	<cfreturn sReturn>
	
	</cffunction>
	<cffunction name="delete" output="true">
		<cfargument name="type" type="String">
		<cfargument name="id" type="numeric">

		<cfset var qDelete = "">
		<cfset var qCheck = "">
		
		<cfif arguments.type eq "">

			Error! no type specified to delete.<cfabort>
		</cfif>
		<!--- STUB: hm, archive? --->
		<!--- check access level --->
		<cfif session.usr.accesslevel lte 2>
			<cfquery name="qDelete" >
			delete from #arguments.type# where #arguments.type#id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			
			<cfreturn "Deleted.">
		<cfelseif session.usr.accesslevel gt 2>
			<cfquery name="qcheck" >
			select * from #arguments.type# where #arguments.type#id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#"> and creator = #session.usr.usrid#
			</cfquery>
			<cfif qcheck.recordcount gt 0>
				<cfquery name="qDelete" >
				delete from #arguments.type# where #arguments.type#id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#"> and creator = #session.usr.usrid#
				</cfquery>
				
				<cfreturn "Deleted.">
			<cfelse>
				<cfreturn "I'm sorry, you may only delete items you created.">
			</cfif>
		<cfelse>
			<Cfreturn "Insufficient privileges">
		</cfif>
		
		</cffunction>
<cffunction name="drawItem" output="true">
	<cfargument name="id">
	<cfargument name="name">
	<cfargument name="type" default="#this.type#">
	<cfargument name="position" default="">
	<cfargument name="itemcount" default="">
	<cfargument name="form" default="">
	
	<cfset var o = "">

	<cfset o =loadData(type=arguments.type,id=arguments.id)>


	<cfset var sReturn = "">
	<cfset var sFilePath = "../"&application.viewpath&"/"&arguments.type&"ItemForm.cfm">
	<cfif fileexists(sFilePath)>
		<cfsavecontent variable="sReturn"><cfoutput>
		<cfinclude template="#sFilePath#">
		</cfoutput></cfsavecontent>
	<cfelse>
		<cfsavecontent variable="sReturn"><cfoutput>
		<cfinclude template="../#application.viewpath#/defaultItemForm.cfm">
		</cfoutput></cfsavecontent>	
	</cfif>
	
	<cfreturn sReturn>
</cffunction>		
<cffunction name="drawItemForm" output="false">
	<cfargument name="id">
	<cfargument name="name">
	<cfargument name="type" default="#this.type#">
	<cfargument name="position" default="">
	<cfargument name="itemcount" default="">
	<cfargument name="form" default="">
	<cfargument name="anchor" default="#arguments.id#">
	

	<cfset var o =loadData(type=arguments.type,id=arguments.id)>


	<cfset var sReturn = "">
	<cfset var sFilePath = "../"&application.viewpath&"/"&arguments.type&"ItemForm.cfm">
	<cfif fileexists(sFilePath)>
		<cfsavecontent variable="sReturn"><cfoutput>
		<cfinclude template="#sFilePath#">
		</cfoutput></cfsavecontent>
	<cfelse>
		<cfsavecontent variable="sReturn"><cfoutput>
		<cfinclude template="../#application.viewpath#/defaultItemForm.cfm">
		</cfoutput></cfsavecontent>	
	</cfif>
	
	<cfreturn sReturn>
</cffunction>
<cffunction name="getdata" output="false">
	<cfargument name="type" default="#this.type#">
	<cfargument name="id" default="">
	<cfargument name="lAdditionalFields" default="">
	<cfargument name="whereClause" default="">
	<cfargument name="sortOrder" default="">
	<cfargument name="searchstring" default="">
	<cfargument name="searchfields" default="">

	<cfset var qget = "">

	<cfif len(arguments.searchfields) eq 0>
		<cfif arguments.type neq "object" and structkeyexists(this,"searchfields")>
			<cfset arguments.searchfields = this.searchfields>
		</cfif>
	</cfif>

	<Cfquery name="qget" >
		select #arguments.type#id, #arguments.type#id as id, #arguments.type#name, #arguments.type#name as name 
		<cfif len(arguments.lAdditionalFields)>, #arguments.lAdditionalFields#</cfif>
		from #arguments.type#
		where 1=1
		<cfif len (arguments.id) and isnumeric(arguments.id)>
			and #arguments.type#id = #arguments.id#
		</cfif>
		<cfif len(arguments.whereClause)>
			#preservesinglequotes(arguments.whereClause)#
		</cfif>
		<cfif len(arguments.searchstring)> <!--- STUB: make this safe from injection --->
			and (
			<cfloop list="#arguments.searchfields#" item="sf">
			<cfif sf neq listfirst(arguments.searchfields)> OR </cfif>
			 #sf# like '%#arguments.searchstring#%'
			</cfloop>
			)
		</cfif>
		<cfif len(arguments.sortOrder)>
			order by #preservesinglequotes(arguments.sortOrder)#
		<cfelse>
		order by #arguments.type#name
		</cfif>
	</cfquery>
	<cfreturn qget>
</cffunction>
<cffunction name="getKeyValues" output="true">
	<cfargument name="pkfield" type="string">
	<cfargument name="pkvalue" type="number">
	<cfargument name="datatable" type="string">
	<cfargument name="datafield" type="string">
	<cfargument name="sortOrder" default="">

	<cfset var qget = "">


	<!--- STUB: this is an insecure query --->
	<cfquery name="qget" >
	select #arguments.datafield# as selected from #arguments.datatable# where #arguments.pkfield# = #arguments.pkvalue#
	<cfif len(arguments.sortOrder)>
	order by #arguments.sortOrder#
	</cfif>
	</cfquery>

	<cfreturn valuelist(qget.selected)>

</cffunction>
<cffunction name="handleEditForm" returntype="String" output="true">
	<cfargument name="formdata">
	<cfargument name="returnnewid" default="false">
	
	<cfset var qSave = "">
	<cfset var qInsepct = "">
	<cfset var qKeyDelete = "">
	<cfset var qKeySave = "">
	<cfset var qmax = "">
	<cfset var targetColumn = "">
	<cfset var lFields = "">
	<cfset var lValues = "">
	<cfset var lDisallowedFields = "datecreated,datelastupdated,id,name,creator">
	<cfset var returnkey = 0>
	<cfset var recordInserted=0>
	
	<cfif isdefined("form.cancel")>
		<cfreturn "Action Canceled">
	</cfif>

	<cfif structkeyexists(arguments.formdata,"type") and len(arguments.formdata.type)>
		<cfset pkfield = arguments.formdata.type & "id">
		<cfset lDisallowedFields = listappend(lDisallowedFields, pkfield)>
		<cfif structkeyexists(arguments.formdata,pkfield) and isnumeric(arguments.formdata[pkfield])>
			<cfset pkvalue = arguments.formdata[pkfield]>
			<!--- get the fields for this type STUB: cache this? --->
			<cfquery name="qInspect" >
			select * from #arguments.formdata.type# where 0 = 1
			</cfquery>
			<cfset lAllowedFields = qInspect.columnlist>

			<!--- STUB: key fields --->
			<cfloop list="#lAllowedFields#" index="f">
				<cfif listfindnocase(lDisallowedFields,f) eq 0>
					<cfif structkeyexists(arguments.formdata, f)>
					<cfset lFields = listappend(lFields,f)>
					<cfset lValues = listappend(lValues,"'" & replace(arguments.formdata[f],"'","''","all") & "'")>
					</cfif>
				</cfif>
				<cfif f eq "creator">
				<cfset lFields = listappend(lFields,"creator")>
				<cfset lValues = listappend(lValues, session.usr.usrid)>
				<cfparam name="arguments.formdata.creator" default="#session.usr.usrid#">
				</cfif>
			</cfloop>

			<!--- automatically set the sortkey to be the last item+1 if no value is supplied --->
			<cfif arguments.formdata.type neq "adhoc" and listfindnocase(lAllowedFields,"sortkey") and not structkeyexists(arguments.formdata,"sortkey")>
				<!--- STUB: problematic hard coding here --->
				<cfif arguments.formdata.type eq "adhoc">
					<Cfset parentcolumn="formfield">
				<cfelse>
					<cfset parentcolumn="form">
				</Cfif>
				<!--- get the current max value and add one --->
				<cfquery name="qmax" >
				select max(sortkey)+1 as newsortkey from #arguments.formdata.type# where #parentcolumn# = #arguments.formdata[parentcolumn]#
				</cfquery>
				<cfif qmax.recordcount eq 0 or qmax.newsortkey eq "">
					<cfset newsortkey = 1>
				<cfelse>
					<cfset newsortkey = qmax.newsortkey>
				</cfif>
				<cfset lFields = listappend(lFields,"sortkey")>
				<cfset lValues = listappend(lValues, newsortkey)>
				<cfset arguments.formdata.sortkey = newsortkey>
			</cfif>
			<!---<cftry>--->
			<cfif pkvalue eq -1 and listlen(lFields) gt 0> <!--- this is a new record --->
				<cfquery name="qsave"  result="db">
					insert into #arguments.formdata.type# ( #lFields#) values ( #preservesinglequotes(lValues)# )
				</cfquery>
				<cfset recordInserted=db.generatedKey>
				<!---evaluate("db.#arguments.formdata.type#id")>--->
				<cfif arguments.returnnewid eq true>
					<cfset returnkey = db.generatedKey>
				</cfif>
			<cfelse>
				<!--- '#replace(arguments.formdata[t],"'","''","all")#' 
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata[t]#">--->
				<cfquery name="qsave" >
				update #arguments.formdata.type#
				set <cfloop list="#lfields#" index="t">#t# = '#arguments.formdata[t]#', </cfloop>
				datelastupdated = current_timestamp
				where #pkfield# = #pkvalue#		
				</cfquery>
				<cfif arguments.returnnewid eq true>
					<cfset returnkey =pkvalue>
				</cfif>
			</cfif>
			<!---<cfcatch type="any">
				<cfreturn "Could not save!" & cfcatch.Message>
			</cfcatch>
			</cftry> --->
			<!--- handle key values - m:m relations --->
			<cfloop collection="#arguments.formdata#" item="f">
				<cfif left(f,3) eq "key" and left(f,7) neq "keyword">
					<!--- get column names... maybe this should someday save a history --->
					<cfquery name="qKeySave" >
					select * from #f# where 0 =1
					</cfquery>
					<cfloop list="#qKeySave.columnlist#" index="p">
						<cfif listfindnocase("#arguments.formdata.type#,creator,datelastupdated,datecreated,#f#id",p) eq 0>
							<cfset targetColumn = p>
							<cfbreak>
						</cfif>
					</cfloop>
					<cfif targetColumn neq "">
						<!--- simply delete existing relations and re-add them --->
						<cfquery name="qKeyDelete" >
						delete from #f# where #arguments.formdata.type# = #pkvalue#
						</cfquery>
						<cfloop list="#arguments.formdata[f]#" index="i">
							<cfquery name="qKeySave" >
							insert into #f# ( #arguments.formdata.type#, #targetColumn# ) values ( #pkvalue#, #i# )
							</cfquery>
						</cfloop>
					</cfif>
				</cfif>
				
			</cfloop>

		</cfif>
	</cfif>
	
	<cfif arguments.returnnewid eq true>
		<cfreturn returnkey>
	<cfelseif recordInserted neq 0>
		<!--- if they have just created this, they will want to edit it. Send them to the edit form.--->
		<cflocation url="#cgi.SCRIPT_NAME#?type=#form.type#&action=configure&#form.type#id=#recordInserted#" addtoken="no">
	<cfelse>
		<cfreturn "Saved.">
	</cfif>
</cffunction>
<cffunction name="loadData" output="false">
	<cfargument name="type" default="#this.type#">
	<cfargument name="id">

	<cfset var oEntity = "">
	<cfset var qGet = "">

	<cfquery name="qget" >
	select * from #arguments.type# where #arguments.type#id = #arguments.id#
	</cfquery>

	<!---<cfif qget.recordcount>--->
		<!---<cfset oEntity = createobject("component",application.modelpath&"."&arguments.type)>
	--->
	<cfset oEntity = structnew()>
	<cfloop list="#qget.columnlist#" index="c">
		<cfset oEntity[c] = evaluate("qget.#c#")>
	</cfloop>
	<cfif structkeyexists(oEntity,"type") eq "no">
		<cfset oEntity.type=arguments.type>
	</cfif>
	<!---<Cfelse>
		<!--- hmmm... what to do with this --->
	</Cfif>--->
	<cfreturn oEntity>
</Cffunction>
<cffunction name="lookUpStruct" output="false">
	<cfargument name="type">

	<!--- STUB: cache the heck out of this --->

	<Cfset var qType="">
	<cfset var stType=structnew()>
	<cfinvoke returnvariable="qType" component="#application.modelpath#.object" type="#arguments.type#" method="getdata"></cfinvoke>
		<cfloop query="qType">
			<cfset stType[qType.id]=qType.name>
		</cfloop>

	<cfreturn stType>
</cffunction>
<cffunction name="namestring" output="false">
	<cfargument name="lastname">
	<cfargument name="firstname">

	<cfset var sReturn = "">

	<cfif len(arguments.lastname) and len(arguments.firstname)>
		<Cfset sReturn = arguments.lastname & ", " & arguments.firstname>
	<cfelseif len(arguments.lastname) and not len(arguments.firstname)>
		<Cfset sReturn = arguments.lastname>
	<cfelseif not len(arguments.lastname) and len(arguments.firstname)>
		<cfset sReturn = arguments.firstname>
	</Cfif>

	<cfreturn sReturn>
</Cffunction>
<cffunction name="queryToArrayOfStructs" output="false">
		<cfargument name="sourceQuery">
		
		<cfset var aReturn = arrayNew()>
		<cfset var stTemp = structNew()>

		<cfif not isquery(arguments.sourceQuery) or arguments.sourceQuery.recordcount eq 0>
			<cfreturn arraynew(1)>
		</cfif>
		
		<cfloop query="arguments.sourceQuery">
			<cfset stTemp = structNew()>
			<cfloop list="#arguments.sourceQuery.columnlist#" index = "c">
				<cfset stTemp[c]=arguments.sourceQuery[c]>
			</cfloop>
			<cfset arrayAppend(aReturn,stTemp)>
	
		</cfloop>
		
		<cfreturn aReturn>
	</cffunction>
<!---<cffunction name="searchTable">
<cfargument name="searchString">
<cfargument name="type">
<cfargument name="lAdditionalFields" default="">

<cfset var qget = "">

<cfquery name="qget">
select 
#arguments.type#id, #arguments.type#id as id, #arguments.type#name, #arguments.type#name as name 
		<cfif len(arguments.lAdditionalFields)>, #arguments.lAdditionalFields#</cfif>
		 from #arguments.type# where #arguments.type#name like '%#arguments.searchstring#%'
</cfquery>

<cfreturn qget>
</cffunction>	--->
<cffunction name="showEditingList" output="true">
	<cfargument name="qData">
	<cfargument name="type" default="#this.type#">
	<cfargument name="lAdditionalFields" default="">
	<Cfargument name="maxitems" default="">
	<cfargument name="showcreateform" default="false">
	<cfargument name="showSearchForm" default="false">

	<cfset var sRetval = '<div class="post">'>
		<cfif arguments.showSearchForm eq true>
			<cfset sRetval = sRetval & '<div><form name="sf" action="#cgi.SCRIPT_NAME#" method="get"><input type="text" name="searchstring"><input type="submit" name="submit" value="Search"><input type="submit" name="clear" value="Clear Search" onclick="document.sf.searchstring.value='''';"></form></div>'>

		</cfif>
		<cfif arguments.showcreateform eq true>
		<cfif not isnumeric(arguments.maxitems) or ( (isnumeric(arguments.maxitems) and qdata.recordcount lt arguments.maxitems) )>
			<cfif not isdefined("url.#arguments.type#id") or (isdefined("url.action") and url.action neq "edit")>
				
				<cfset sRetval = sRetval & "<div>"& drawItemForm(-1,"",arguments.type) & "</div>">
			</cfif>
		<cfelse>
			<cfset sRetval = sRetval & "<div>Maximum number of items reached (#arguments.maxitems#).</div>">
		</cfif>
	</cfif>
	<cfloop query="qdata">
		<cfif isdefined("url.#arguments.type#id") and url["#arguments.type#id"] eq qdata.id and isdefined("url.action") and url.action eq "edit">
			<cfset sRetval = sRetval & drawItemForm(qdata.id,qdata.name,arguments.type)>
		<cfelse>
			<cfset sRetval = sRetval & '<article> <a href="#cgi.SCRIPT_NAME#?type=#arguments.type#&#arguments.type#id=#qdata.id#&action=configure">#qdata.name#</a>'>
				<!---' <a href="#cgi.SCRIPT_NAME#?#arguments.type#id=#qdata.id#&action=edit">[ Rename ]</a>'>--->
			<cfif len(arguments.lAdditionalFields)>
				<cfloop list="#arguments.lAdditionalFields#" index="item">
					<cfset sRetval = sRetval & "&nbsp;" & evaluate("qData.#item#")>
				</cfloop>
			</cfif>
			<!--- STUB: add confirmations --->
			<cfset sRetval = sRetval & '&nbsp;<a href="#cgi.SCRIPT_NAME#?type=#arguments.type#&#arguments.type#id=#qdata.id#&action=delete" onClick="javascript: return confirm(''delete this item?'')">[ Delete ]</a>'>
			<!---<cfset sRetval = sRetval & '&nbsp;<a href="#cgi.SCRIPT_NAME#?type=#arguments.type#&#arguments.type#id=#qdata.id#&action=configure">[ Configure ]</a>'>
			--->
			<cfset sRetval = sRetval & '</article>'>
		</cfif>
	</cfloop>
	<cfset sRetval = sRetval & "</div>">
	<cfreturn sRetval>

	</cffunction>
	
	
</cfcomponent>
