<cfinvoke component="control.flow" method="handleForm" returnvariable="sMessage"></cfinvoke>

<cfif len(sMessage)>
	<cfoutput>
	<p class="userfeedback">#sMessage#</p>
	</cfoutput>
</cfif>
	
<h1>Events</h1>
	

<cfinvoke component="#application.modelpath#.event" method="getData" returnvariable="qEvent" ></cfinvoke>



<cfset allowCreate = false>
<cfif session.usr.accesslevel eq 1 and len(url.searchstring) eq 0>
	<cfset allowCreate = true>
</cfif>
<cfinvoke component="#application.modelpath#.event" method="showEditingList" returnvariable="sEditList" qData="#qEvent#" showcreateform="#allowCreate#" showSearchForm="true"></cfinvoke>
<cfoutput>#sEditList#</cfoutput>