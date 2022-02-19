<cfset oWriter = createObject("component", application.modelpath&".form")>
<cfoutput>
<form action="#cgi.script_name#" method="post">
	#oWriter.write(fieldType="radio",stForm="#o#",fieldName="projectstatus",optionData="projectstatus")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldName="projectname")#
	#oWriter.write(fieldType="textarea",stForm="#o#",fieldName="projectdescription")#
	#oWriter.write(fieldType="selector",stForm="#o#",fieldName="projectsponsor",optiondata="usr")#

	#oWriter.write(fieldType="textinput",stForm="#o#",fieldname="cluster")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldname="location")#
	#oWriter.write(fieldType="checkbox",stForm="#o#",fieldName="keyprojectcoreactivity",optiondata="coreactivity")#
	#oWriter.write(fieldType="textarea",stForm="#o#",fieldName="goalscomment")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldname="directengagement")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldname="indirectengagement")#
	#oWriter.write(fieldType="textinput",stForm="#o#",fieldname="growth")#
	#oWriter.write(fieldType="textarea",stForm="#o#",fieldName="learningcyclecomment")#
	#oWriter.write(fieldType="textarea",stForm="#o#",fieldName="lessonslearnedcomment")#
	#oWriter.write(fieldType="textarea",stForm="#o#",fieldName="nextstepscomment")#
	#oWriter.write(fieldType="radio",stForm="#o#",fieldName="leadership",optiondata="leadership")#
	#oWriter.write(fieldType="textarea",stForm="#o#",fieldName="portabilitycomment")#

	#oWriter.write(fieldType="checkbox",stForm="#o#",fieldName="keykeywordproject",optiondata="keyword")#

	<div class="formcontrols">
	<input type="submit" name="submit" value="Submit">
	<input type="submit" name="cancel" value="Cancel">
	<input type="hidden" name="projectid" value="#o.projectid#">
	<input type="hidden" name="type" value="project">
	<input type="hidden" name="action" value="configure">
	</div>
</form>
</cfoutput>