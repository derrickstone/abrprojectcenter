<!--- this page will generally be replaced by an enterprise login --->
<!--- STub: add reset password link & prevent multiple logins 
STUB: add validation for entry fields --->

<cfif isdefined("form.usrname") and len(form.usrname)>

	<cfif isdefined("form.password") and len("form.password")>

		<cfinvoke component="#application.modelpath#.usr" method="login" usrname="#form.usrname#" pwd="#form.password#" returnvariable="token" >

		<cfif len(token)>

			<Cfcookie name="usrname" value="#form.usrname#">
			<cfcookie name="token" value="#token#">
			
			<cfinvoke component="#application.modelpath#.usr" method="init" returnvariable="u" usrname="#form.usrname#" token="#token#">
			
			<cflock scope="session" type="exclusive" timeout="10">
				<Cfset session.usr = u>
			</cflock>
			<cflocation url="/index.cfm" addtoken="no">
		<cfelse>
			
			<p class="userfeedback">I'm sorry, that username and password combination does not match anything in our database.</p>
		</Cfif>

	</cfif> 
</cfif>
<h1>Login</h1>
<div>
	<p>
		<a href="/login/saml">[ Login with your organization ]</a>
	</p>
<form method="post" action="index.cfm">
	<div>
		<label for="usrname">Username</label>
		<input id="usrname" type="text" name="usrname"> 
	</div>
	<div>
		<label for="password">Password</label>
		<input id="password" type="password" name="password">
	</div>
	<div>
		<input type="submit" name="submit" value="submit">
	</div>
	<br />
	<div>
		<div class="g-signin2" data-onsuccess="onSignIn"></div>
	</div>
</form>

<a href="register.cfm">[ Register for an Account ]</a>

</div>

<cfif url.debug eq 1>
	<cfdump var="#session#">
</cfif>
<script>
	function onSignIn(googleUser) {
  var profile = googleUser.getBasicProfile();
  console.log('ID: ' + profile.getId()); // Do not send to your backend! Use an ID token instead.
  console.log('Name: ' + profile.getName());
  console.log('Image URL: ' + profile.getImageUrl());
  console.log('Email: ' + profile.getEmail()); // This is null if the 'email' scope is not present.
}
</script>