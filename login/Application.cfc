<!---
  --- application
  --- -----------
  ---
  --- author: derrick
  --- date:   5/17/19
  --->
<cfcomponent accessors="true" output="false" persistent="false">
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
<cffunction name="onapplicationstart">
	

	<cflock scope="application" timeout="10" type="exclusive">
		<cfset application.viewpath="/login/view">
		<Cfset application.modelpath="model">
		

	</cflock>
</cffunction>
<cffunction name="onrequeststart" output="true">
	<cfparam name="url.reset" default="0">
	<cfparam name="url.debug" default="0">

	<cfif url.reset eq 1>
		<cfset onapplicationstart()>
	</cfif>

	<cfinclude template="/login/view/head.cfm">
	<cfinclude template="/login/view/bodytop.cfm">
</cffunction>
<cffunction name="onrequestend" output="true">
	<cfinclude template="/login/view/bodybottom.cfm">	
</cffunction>
</cfcomponent>