<cfcomponent>

<cffunction name="generateMessage">
	<cfargument name="linktext">
	<cfargument name="messagetypeid">

	<cfset var sReturn = "">

	<cfswitch expression="#arguments.messagetypeid#">
		<cfcase value="1"><!--- workflow notice --->
			<cfsavecontent variable="sReturn"><cfoutput>
				---------
	Please follow the link below to approve or return this form in process. 

	#arguments.linktext#

	To simply approve a request, you may also reply to this message with the word approve as the first line of the message, followed by any comments you would like to have saved with your approval. Use the word return as the first line to return the request to the original requestor. When returning a request, additional comments are required.
			</cfoutput></cfsavecontent>
		</cfcase>
		<Cfcase value="2"> <!--- ready for completion --->
			<cfsavecontent variable="sReturn"><cfoutput>
			---------
			Please follow the link below to complete this form in process. 

			#arguments.linktext#
			</cfoutput></cfsavecontent>
		</Cfcase>
		<cfcase value="3"> <!--- submission complete --->
			<cfsavecontent variable="sReturn"><cfoutput>
			---------
			This submission is complete.

			#arguments.linktext#	
			</cfoutput></cfsavecontent>
		</cfcase>
		<cfcase value="4"> <!--- submission returned --->
			<cfsavecontent variable="sReturn"><cfoutput>
			---------
			This submission has been returned. To continue processing of this form, review comments made by the reviewers, make corrections as indicated, and re-submit.

			#arguments.linktext#

			</cfoutput></cfsavecontent>
		</cfcase>
		<cfcase value="5"> <!--- submission step approved --->
			<cfsavecontent variable="sReturn"><cfoutput>
			---------
			A review step has completed successfully.

			#arguments.linktext#

		</cfoutput></cfsavecontent>
		</cfcase>
		<cfdefaultcase>
			<Cfset sReturn="#linktext#">
		</cfdefaultcase>
	</cfswitch>

	<cfreturn sReturn>
</cffunction>
</cfcomponent>
