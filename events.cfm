<cfinvoke component="control.flow" method="handleForm" returnvariable="sMessage"></cfinvoke>

<cfif len(sMessage)>
	<cfoutput>
	<p class="userfeedback">#sMessage#</p>
	</cfoutput>
</cfif>
	
<h1>Events</h1>
	

<cfinvoke component="#application.modelpath#.event" method="getData" returnvariable="qEvent" ></cfinvoke>


<cfinvoke component="#application.modelpath#.event" method="showEditingList" returnvariable="sEditList" qData="#qEvent#" ></cfinvoke>
<cfoutput>#sEditList#</cfoutput>