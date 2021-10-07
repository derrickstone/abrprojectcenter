<cfif isdefined("form.submit") and form.submit eq "cancel">
	<cflocation url="/login/index.cfm" addtoken="no">
</cfif>
<cfif isdefined("form.submit") and form.submit eq "Submit" and isdefined("form.confirmation") and isvalid("UUID",form.confirmation)>

	<cfquery name="qcheckusrname" datasource="#application.dsn#">
	select * from usr where usrname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.usrname#">
	</cfquery>
	<cfif qcheckusrname.recordcount gt 0>
		<p>I'm sorry, that usrname is in use. Please try something else, or <a href="/login/passwordreset.cfm">reset your password</a>.</p>
	</cfif>
	<cfif isvalid("email",form.email)>

		<!--- Check for a unique email --->

		<cfquery name="qcheck" datasource="#application.dsn#">
		select usrid from usr where email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">
		</cfquery>
		<cfif qcheck.recordcount eq 0>

			<cfquery name="qInsert" datasource="#application.dsn#">
			insert into usr ( firstname, lastname, email, usrname, password, confirmation ) values (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstname#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastname#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.usrname#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.password#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.confirmation#">
				)
			</cfquery>
			<p>New user saved - check your email for a confirmation.</p>
		<cfelse>
			<p>That email address is already in use! Do you need to <a href="/login/passwordreset.cfm">reset your password?</a></p>
		</cfif>
	<cfelse>

		<p>Please provide a valid email address.</p>
	</cfif>

</cfif>
<h1> Register for an Account </h1>

<p id="userfeedback">Please complete the following fields to create your user account. Note that a valid email address is required.</p>

<form id="regform" action="register.cfm" method="post" onsubmit="return validate();">

<div>
<label for="firstname">First Name</label>
<input type="textinput" name="firstname" id="firstname" required>
</div>

<div>
<label for="lastname">Last Name</label>
<input type="textinput" name="lastname" id="lastname" required>
</div>

<div>
<label for="email">Email</label>
<input type="textinput" name="email" id="email" required>
</div>

<div>
<label for="usrname">Username (uvaid)</label>
<input type="textinput" name="usrname" id="usrname" required>
<p>Your UVAID</p>
</div>

<div>
<label for="password">Password</label>
<input type="password" name="password" id="password" required>
<label for="password2">Confirm Password</label>
<input type="password" name="password2" id="password2" required>
<p>at least 8 characters</p>
</div>

<div>
<label for="turing">Am I a robot?</label>
<span id="turing">
<input type="radio" name="turing" checked value="Yes" onclick="testHaxxor();">Yes
<input type="radio" name="turing" value="No" onclick="testHaxxor();">No
</span>
</div>

<input type="submit" name="submit" value="Submit">
<a href="/login/index.cfm">[ Cancel ]</a>
<!---<input type="submit" name="cancel" value="Cancel">--->
<input type="hidden" name="confirmation" value="">

</form>

<script>
	<!--- STUB: make this smarter --->
function testHaxxor() {
	document.registrationform.confirmation.value=<cfoutput>'#createuuid()#'</cfoutput>;
}

function validate() {
	if ( document.getElementById('regform').elements('password').value.length < 8 ) {
		userFeedback('Your password should be at least eight characters.');
		return false;
	}
	if (document.getElementById('regform').elements('password').value != document.getElementById('regform').elements('password2').value) {
		userFeedback('The two password fields do not match.');
		return false;
	}
	return true;
}
function userFeedback(msg) {
	document.getElementById('userfeedback').innerHTML=msg;
}
</script>
