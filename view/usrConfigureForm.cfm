<cfset oWriter = createObject("component", application.modelpath&".form")>
<a href="users.cfm">[ Return to List ]</a>
<cfoutput>
	<h2>User Information</h2>
<form action="#cgi.script_name#" method="post">

#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="lastname")#

#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="firstname")#

#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="email")#

#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="usrname")#


<cfif o.holdmail eq "">
	<cfset o.holdmail = 0>
</cfif>
#oWriter.write(fieldtype="radio",optiondata="yesno",stForm="#o#",fieldname="holdmail",htmlid="hm")#

<cfif session.usr.accesslevel lte 2>
#oWriter.write(fieldType="radio",stForm="#o#",fieldName="accessLevel",optionData="accesslevel",htmlid="al")#

#oWriter.write(fieldType="textInput",stForm="#o#",fieldName="password",htmlid="pw")#

#oWriter.write(fieldType="checkbox",fieldName="keykeywordusr",optiondata="keyword",stForm="#o#")#
</cfif>
<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="usrid" value="#o.usrid#">
	<input type="hidden" name="type" value="usr">
	<input type="hidden" name="action" value="configure">
	</div>

</form>
</cfoutput>