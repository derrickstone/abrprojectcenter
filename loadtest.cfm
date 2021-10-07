<!--- test generation of many records --->

<cfparam name="url.formid">
<cfparam name="url.action">
<cfparam name="url.count">


<cfif url.action eq "add">
	<cfif isnumeric(url.count) and isnumeric(url.formid)>

		<cfinvoke component="#application.modelpath#.form" method="getdata" formid="#url.formid#" returnvariable="qForm"></cfinvoke>
		<cfif qForm.recordcount gt 0>
			Found the form.
		</cfif>
	</cfif>

<cfelseif url.action eq "remove">
	<cfinvoke component="#application.modelpath#.form" method="getdata" formid="#url.formid#" returnvariable="qForm"></cfinvoke>

	
<cfelse>
	No known action specified.
</cfif>

<br />
Done.