
<cfinvoke component="control.flow" method="handleForm" returnvariable="sMessage"></cfinvoke>

<cfif len(sMessage)>
	<cfoutput>
	<p class="userfeedback">#sMessage#</p>
	</cfoutput>
</cfif>
	
<h1>Project</h1>
	

<cfinvoke component="#application.modelpath#.project" method="getData" returnvariable="qProject" ></cfinvoke>


<cfinvoke component="#application.modelpath#.project" method="showEditingList" returnvariable="sEditList" qData="#qProject#" ></cfinvoke>
<cfoutput>#sEditList#</cfoutput>


