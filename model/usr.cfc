<cfcomponent extends="object">
<cfset this.type="usr">
<cfset this.searchfields="usrname,firstname,lastname">
<cffunction name="getMyForms" hint="Get a list of forms submitted by this user." output="false">

	<cfargument name="usr">

	<Cfset var qget = "">

	<cfquery name="qget" >
	select * from form where 0 =1
	</cfquery>
	
	<cfreturn qget>
</cffunction>
<cffunction name="getOrganizations" output="false">
	<cfargument name="usrid">

	<cfset var qget =  "">

	<cfquery name="qget" >
	 select o.organizationname, o.organizationid, uo.accesslevel from organization o
	 inner join usrorganization uo on uo.organization = o.organizationid
	 where uo.usr = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usrid#">
	 order by o.organizationname
	</cfquery>

	<cfreturn qget>
</cffunction>

<cffunction name="getSuperUsrs" output="false">
	<cfset var qget = "">

	<cfquery name="qget" >
	select *, usrid as id, usrname as name from usr where accesslevel = 1
	</cfquery>
	<cfreturn qget>
</cffunction>
<cffunction name="getUsr" output="false">
	<cfargument name="usrid">
	<cfset var qget = "">
	<cfquery name="qget"  cachedwithin="#createtimespan(0,1,0,0)#">
		select * from usr where usrid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.usrid#">
	</cfquery>

	<cfreturn qget>
</cffunction>
<cffunction name="getUsrIdFromEmail" output="false">
	<cfargument name="email">
	<cfset var qget = "">
	<cfquery name="qget"  cachedwithin="#createtimespan(0,1,0,0)#">
		select usrid from usr where lower(email) = lower(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">)
	</cfquery>

	<cfif qget.recordcount>
		<cfreturn qget.usrid>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>
<cffunction name="init" output="false">
	<cfargument name="usrname">
	<cfargument name="token">

	<cfset var qget = "">
	<cfset var qvalidate = "">
	<Cfset var oUser=structnew()>

	<cfquery name="qvalidate" >
		select * from usrtoken where usrname=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.usrname#"> and token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.token#">
	</cfquery>

	<cfif qvalidate.recordcount>

		<cfquery name="qget" >
			select * from usr where usrname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.usrname#">
			
		</cfquery>

		<cfif qget.recordcount gt 0>
			<cfset oUser.usrname=qget.usrname>
			<Cfset oUser.firstname=qget.firstname>
			<Cfset oUser.lastname=qget.lastname>
			<cfset oUser.email=qget.email>
			<cfset oUser.datecreated=qget.datecreated>
			<Cfset oUser.datelastupdated=qget.datelastupdated>
			<Cfset oUser.usrid=qget.usrid>
			<cfset oUser.accesslevel = qget.accesslevel>
			
		</cfif>
	
	</cfif>

	<Cfreturn oUser>

</cffunction>
<cffunction name="login" output="false">
	<Cfargument name="usrname">
	<cfargument name="pwd">

	<cfset var qCheckLogin = "">
	<cfset var token = "">

	<cfquery name="qCheckLogin">
	select usrid from usr where usrname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.usrname#">
	and password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pwd#">
	</cfquery>

	<cfif qCheckLogin.recordcount>
		<!--- valid usrname and password, create and return a token --->
		<cfset token = createUUID()>
		<cfquery name="qCreateToken" >
		insert into usrtoken ( usrname, token ) values ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.usrname#">, <Cfqueryparam cfsqltype="cf_sql_varchar" value="#token#"> ) 
		</cfquery>
	<cfelse>
		<Cfset token = "">
	</cfif>

	<cfreturn token>
	</cffunction>
<cffunction name="samllogin" output="false">
	
	<!--- this must create a record if one does not exist;
	what happens when a user is created because their email address has been added
	and no usrname has been assigned?
	What happens with a failed login?
	--->

	<cfset var qFindUsr1 = "">
	<cfset var qCreateToken = "">
	<cfset var qAddUsr = "">
	<cfset var qUpdateUsr = "">
	<cfset var token = createUUID()>
	<cfset var returnHeaders = structnew()>

	<cfset returnHeaders = GetHttpRequestData().headers>

	<cfquery name="qFindUsr1" >
	select usrid from usr where usrname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.remote_user#">
	</cfquery>
	

	<cfif qFindUsr1.recordcount neq 0>
		<!--- update user record here 
			this is a new user to the system--->
		<cfquery name="qUpdateUsr" >
		update usr set firstname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.givenName#">, lastname=<cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.sn#">, email=<cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.mail#">, sisid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.employeeNumber#">
		 where usrname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.remote_user#">
		</cfquery>
		
	<cfelse>
		<!--- create a usr record from the saml information --->
		<cfquery name="qAddUsr" >
		insert into usr ( firstname, lastname, usrname, accesslevel, email, sisid ) values ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.givenName#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.sn#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.remote_user#">, 4, <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.mail#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.employeeNumber#"> )
		</cfquery>
	</cfif>

	<cfquery name="qCreateToken" >
		insert into usrtoken ( usrname, token ) values ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#returnHeaders.remote_user#">, <Cfqueryparam cfsqltype="cf_sql_varchar" value="#token#"> ) 
		</cfquery>

		<Cfcookie name="usrname" value="#returnHeaders.remote_user#">
		<cfcookie name="token" value="#token#">

	<cfreturn token>
	</cffunction>
</cfcomponent>