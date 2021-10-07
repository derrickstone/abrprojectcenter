<!---
  --- author: derrick
  --- date:   5/17/19
  --->
<cfcomponent accessors="true" output="false" persistent="false" >
<cfset this.name="setcomposer">
<cfset this.sessionmanagement="true">
	<cfscript>
	this.datasources["setcomposer"] = {
	  class: 'com.mysql.cj.jdbc.Driver'
	, bundleName: 'com.mysql.cj'
	, bundleVersion: '8.0.19'
	, connectionString: 'jdbc:mysql://localhost:3306/setcomposer?characterEncoding=UTF-8&serverTimezone=America/New_York&maxReconnects=3'
	, username: 'scuser'
	, password: "encrypted:a4ee024baa5177c549dbf3d6fc98f33417cc4ab334ae101715ddc3e4d0631969675056a430c1bd6c"
	
	// optional settings
	, connectionLimit:100 // default:-1
	, liveTimeout:60 // default: -1; unit: minutes
	, alwaysSetTimeout:true // default: false
	, validate:false // default: false
};
	this.defaultDatasource="setcomposer";
	</cfscript>

<cffunction name="onapplicationstart" output="false">



	<cflock scope="application" timeout="10" type="exclusive">
		<cfset application.rootpath = "/var/www/html/">
		<cfset application.viewpath="view">
		<Cfset application.modelpath="model">
		
		<cfset application.filestoragepath = "files">
		
	</cflock>
</cffunction>
<!---
<cffunction name="onError">
	<cfargument name="Exception" required=true/>
	<cfargument type="String" name="EventName" required=true/>
	
	<!--- Display an error message if there is a page context. --->
	<cfif NOT (Arguments.EventName IS "onSessionEnd") OR
	(Arguments.EventName IS "onApplicationEnd")>
	<cfoutput>
	<h2>An unexpected error occurred.</h2>
	<p>Please provide the following information to technical support:</p>
	<p>Error Event: #Arguments.EventName#</p>
	<p>Error details:<br>
	<cfdump var=#Arguments.Exception#></p>
	</cfoutput>
	</cfif>
</cffunction>
--->
<cffunction name="onrequeststart" output="true">
	<cfsilent>
	<cfparam name="url.reset" default="0">
	<cfparam name="url.debug" default="0">
	<cfparam name="url.showtemplate" default="1">

	<cfif url.reset eq 1>
		<cfset onapplicationstart()>
	</cfif>

	<!--- is this user logged in? --->


	<cfif not isdefined("session.usr") or url.reset eq 1>

		<cfif  isdefined("cookie.usrname") and  isdefined("cookie.token") >
		
			<cfinvoke component="#application.modelpath#.usr" method="init" returnvariable="u" usrname="#cookie.usrname#" token="#cookie.token#">
			</cfinvoke>
			<cfif not structisempty(u)>
				<cflock scope="session" type="exclusive" timeout="10">
					<cfset session.usr = u>
				</cflock>
			</cfif>
		</cfif>
	</cfif>
	<cfif not isdefined("session.usr") or structisempty(session.usr)>
		<cflocation url="/login/index.cfm" addtoken="no">
	</cfif>

</cfsilent>
	
	<!--- STUB: Room to do some caching here --->
	<cfinclude template="view/head.cfm">
	<cfif url.showtemplate eq 1>
	<cfinclude template="view/bodytop.cfm">
  </cfif>
</cffunction>
<cffunction name="onrequestend" output="true">
	
	<cfif url.showtemplate eq 1>
		<cfinclude template="view/bodybottom.cfm">	
	<cfelse>
		<cfinclude template="view/menu.cfm">
	</cfif>
	<cfif url.debug eq 1>
		<cfdump var="#session#">
	</cfif>
</cffunction>
</cfcomponent>