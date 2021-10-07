<cfset oWriter = createObject("component", application.modelpath&".form")>
<a href="users.cfm">[ Return to List ]</a>
<cfoutput>
	<h2>User Information</h2>
<form action="#cgi.script_name#" method="post">

#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="lastname")#
<br />
#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="firstname")#
<br />
#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="email")#
<br />
#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="usrname")#

<br />
<cfif o.holdmail eq "">
	<cfset o.holdmail = 0>
</cfif>
#oWriter.write(fieldtype="radio",optiondata="yesno",stForm="#o#",fieldname="holdmail",htmlid="hm")#
<br />
<cfif session.usr.accesslevel lte 2>
#oWriter.write(fieldType="radio",stForm="#o#",fieldName="accessLevel",optionData="accesslevel",htmlid="al")#
<br />
#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="password",htmlid="pw")#
<br />
</cfif>
<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="usrid" value="#o.usrid#">
	<input type="hidden" name="type" value="usr">
	<input type="hidden" name="action" value="configure">
	</div>
<h3>Relation to resources, projects, events</h3>
</form>
</cfoutput>