<cfparam name="url.type" default="resources">
<cfparam name="url.keyword" default="">

<cfoutput>
<div><formgroup>
<form action="#cgi.script_name#" method="get">
<!--- search by type, keyword and text search --->

<div>
	<cfset lTypes="resource,project,event,usr">
	<cfloop list="#lTypes#" item="t">
		<input type="checkbox" name="type" value="#t#" <cfif listfindnocase(url.type,t)>checked</cfif> id="type#t#"><label for="type#t#">#t#</label>
	</cfloop>
</div>
<div>
	<cfinvoke component="#application.modelpath#.keyword" method="getData" returnvariable="qKeywords"></cfinvoke>
	<cfloop query="qKeywords">
		<input type="checkbox" name="keyword" value="#qKeywords.keywordid#" <cfif listfindnocase(url.keyword,qkeywords.keywordid)>checked</cfif> id="keyword#qKeywords.keywordname#"><label for="keyword#qKeywords.keywordname#">#qKeywords.keywordname#</label>
	</cfloop>
</div>

<input type="text" name="searchstring">
<input type="submit" name="submit" value="Search">
</form>
</formgroup>

<cfif structkeyexists(url,"submit") and url.submit eq "Search">

<cfinvoke component="#application.modelpath#.search" method="search" options="#url#" returnvariable="qResults"></cfinvoke>
<ul>
	<cfif qResults.recordcount gt 0>
	<cfloop query="qResults">
		<li><a href="#qresults.type#.cfm?type=#qresults.type#&#qresults.type#id=#qresults.id#&action=configure">#qResults.name#</a></li>
	</cfloop>
	<cfelse>
		<li>Sorry, no results found</li>
		</cfif>
	</ul>
</cfif>

	</div>
</Cfoutput>