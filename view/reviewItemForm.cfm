<cfset oWriter = createObject("component", application.modelpath&".form")>

<cfoutput>

<form action="#cgi.SCRIPT_NAME#?type=review&approvaldataid=#arguments.stReview.approvaldata#&responsedataid=#arguments.stReview.responsedata#" method="post">
			<!--- Hmmmm.... create a from 'object' to hold current data --->
	<cfset o = arguments.stReview>
	<cfset htmlkey = "f"&arguments.stReview.approvaldata&arguments.stReview.reviewid&arguments.usr>
<div>
	<cfinvoke component="#application.modelpath#.usr" method="getUsr" usrid="#arguments.usr#" returnvariable="udata"></cfinvoke>
	<p>Review requested from #udata.lastname#, #udata.firstname# &lt;#udata.email#&gt;
	<cfif not isnumeric(arguments.stReview.reviewid) or arguments.stReview.reviewid lte 0>
		Provide a new review
	<cfelse>
		Existing review
	</cfif>
</div>

	#oWriter.write(fieldtype="radio",fieldName="responsetype",stForm=o,optionData="responseType",htmlid="ar"&htmlkey,readonly=arguments.bDrawReadOnly)#
	
	#oWriter.write(fieldtype="textarea",fieldName="approvalcomment",stForm=o,htmlid="uc"&htmlkey,readonly=arguments.bDrawReadOnly)#
	
	<input type="hidden" name="type" value="review">
	<input type="hidden" name="reviewid" value="#arguments.stReview.reviewid#">
	<input type="hidden" name="usr" value="#arguments.usr#">
	<input type="hidden" name="approvaldata" value="#arguments.stReview.approvaldata#">
	<input type="hidden" name="responsedata" value="#arguments.stReview.responsedata#">

	<input type="submit" name="submit" value="Save">
	<input type="submit" name="submit" value="Cancel">

	<cfif arguments.stReview.approvalid neq -1>
		<input type="submit" name="submit" value="Delete" onClick="return confirm('Are you sure you want to delete this item?');">
		
	</cfif>
</form>

</cfoutput>
