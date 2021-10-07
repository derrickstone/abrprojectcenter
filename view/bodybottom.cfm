<footer>
	&copy; 2021 ABR Task Force
<cfif structkeyexists(session,"usr")>Logged in as <cfoutput>#session.usr.usrname#</cfoutput>
	<a href="profile.cfm">[ My Profile ]</a>
	<a href="/login/logout.cfm">[ Log out ]</a><br />
</cfif>
</footer>
		</div>
		</div>
		<!-- Scripts -->
			<script src="assets/js/jquery.min.js"></script>
			<script src="assets/js/jquery.scrollex.min.js"></script>
			<script src="assets/js/jquery.scrolly.min.js"></script>
			<script src="assets/js/browser.min.js"></script>
			<script src="assets/js/breakpoints.min.js"></script>
			<script src="assets/js/util.js"></script>
			<script src="assets/js/main.js"></script>

	</body>
</html>