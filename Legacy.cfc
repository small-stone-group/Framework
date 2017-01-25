<!--- Legacy functions that are not supported in cfscript in CF9 --->
<!--- Do not delete --->
<cfcomponent>
    <cffunction name="constructModelObject" access="public" returntype="struct">
        <cfargument name="table" type="string" required="true">
        <cfset var loc = {}>
        <cfset loc.result = {
            "data" = {},
            "columns" = [],
            "columnTypes" = {},
            "nullColumns" = [],
            "primaryKeyField" = ""
        }>

        <cfquery name="loc.schema" datasource="#getDatasource()#">
            DESCRIBE #arguments.table#
        </cfquery>

        <cfloop query="loc.schema">
            <cfset loc.type = parseType(type)>
            <cfset loc.rowIsNull = loc.schema.getString("default")>

            <cfif arrayContains(["int","int unsigned"], loc.type) AND default eq "">
                <cfset default = 0>
            </cfif>

            <cfif NOT structKeyExists(loc, "rowIsNull")>
                <cfset arrayAppend(loc.result.nullColumns, field)>
            </cfif>

            <cfset structInsert(loc.result.data, field, default)>
            <cfset arrayAppend(loc.result.columns, field)>
            <cfset structInsert(loc.result.columnTypes, field, loc.type)>

            <cfif key eq "PRI">
                <cfset loc.result.primaryKeyField = field>
                <cfset loc.result.data[field] = -1>
            </cfif>
        </cfloop>

        <cfreturn loc.result>
    </cffunction>

    <cffunction name="parseType" access="private" returntype="string">
        <cfargument name="value" required="true" type="string">
        <cfreturn reReplace(arguments.value, "\([\d\D]*\)", "", "all")>
    </cffunction>

    <cffunction name="cookie" access="public" returntype="void">
        <cfargument name="c_name" required="true" type="string">
        <cfargument name="c_value" required="true" type="string">
        <cfargument name="c_expires" required="true" type="string">

        <cfif structKeyExists(cookie, c_name)>
            <cfcookie
                name = "#c_name#"
                value = "#c_value#"
                expires = "#c_expires#">
        </cfif>
    </cffunction>

    <cffunction name="fileToLines" access="public" returntype="array">
        <cfargument name="filePath" required="true" type="string">
        <cfset var lines = []>

        <cfloop file="#filePath#" index="line">
            <cfset arrayAppend(lines, line)>
        </cfloop>

        <cfreturn lines>
    </cffunction>

    <cffunction name="createTokenCookie" access="public" returntype="void">
        <cfargument name="token" required="true" type="string">
        <cfcookie name="cfuser" value="#token#" httponly="true" expires="never">
    </cffunction>

    <cffunction name="invokeMethod" access="public" returntype="void">
        <cfargument name="c" required="true" type="string">
        <cfargument name="m" required="true" type="string">
        <cfargument name="a" required="true" type="struct">
        <cfargument name="o" required="false" type="array" default="[]">

        <cfset var oi = 0>

        <cfinvoke
            component="#c#"
            method="#m#">

            <cfloop array="#o#" index="oi">
                <cfinvokeargument
                    name="#oi#"
                    value="#a[oi]#">
                </cfinvokeargument>
            </cfloop>
        </cfinvoke>
    </cffunction>
</cfcomponent>
