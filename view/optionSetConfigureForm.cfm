<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
<form action="#cgi.script_name#?optionsetid=#url.optionsetid#&type=optionset&action=configure" method="post">
	<h2>Set Values</h2>
	<div><h3>#o.optionsetname#</h3>

	<p>Enter each element of the set on a separate line. Sets cannot contain duplicate values.</p>

	<cfinvoke component="#application.modelpath#.optiondata" method="getdata" returnvariable="qValues" optionsetid="#o.optionsetid#"></cfinvoke>
	<textarea name="setData"><cfloop query="qValues">#qValues.value#<cfif qValues.currentRow neq qValues.recordcount>#chr(13)##chr(10)#</cfif></cfloop></textarea>
	</div>
	<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel / Close">
	<input type="hidden" name="optionsetid" value="#o.optionsetid#">
	<input type="hidden" name="type" value="set">
	<input type="hidden" name="action" value="configure">
	</div>
</form>	

</cfoutput>
<cfabort>