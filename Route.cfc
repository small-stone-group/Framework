component
{
    this.ignore = [];
    this.ignoreExtensions = ['.cfm', '.cfml', 'html', 'htm', 'ico'];

    /**
     * Constructor function for the component.
     *
     * @return any
     */
    public any function init(string controller = "", string method = "")
    {
        if (!structKeyExists(request, 'routes')) {
            structInsert(request, 'routes', []);
        }

        if (controller == "" && method == "") {
            return this;
        }

        if (findNoCase("@", controller) > 0) {
            // Found @ - find method in controller
            var identifiers = listToArray(controller, "@");
            controller = identifiers[1];
            method = identifiers[2];
        }

        return getUrl('App/Framework/Request.cfm?controller=#controller#&method=#method#');
    }

    /**
     * Handles the request.
     *
     * @return any
     */
    public any function handle(string requestedPage = '')
    {
        if (structKeyExists(url, "controller") && structKeyExists(url, "method")) {
            var component = createObject("component", "App.Controllers.#url.controller#");
            var method = component.getMethod(url.method);
            method(form);
            return this;
        }

        if (lCase(stripSlashes(cgi.script_name)) != 'index.cfm') {
            include requestedPage;
            return this;
        }

        var payloadURI = (structKeyExists(url, 'url_payload')) ? url.url_payload : '/';
        var r = route().findURI(payloadURI);

        if (!isValid('array', r)) {
            r.perform(r.params);
        } else {
            include requestedPage;
        }

        return this;
    }

    /**
     * Adds a GET HTTP request to the pool.
     *
     * @return any
     */
    public any function get(required string uri, required string action)
    {
        var routeURI = new App.Framework.RouteURI('get', uri, action);
        arrayAppend(request.routes, routeURI);
        return routeURI;
    }

    /**
     * Adds a POST HTTP request to the pool.
     *
     * @return any
     */
    public any function post(required string uri, required string action)
    {
        var routeURI = new App.Framework.RouteURI('post', uri, action);
        arrayAppend(request.routes, routeURI);
        return routeURI;
    }

    /**
     * Establishes a resource route.
     * Also creates the file if it doesn't already exist.
     *
     * @return any
     */
    public any function resource(required string page, required string controller)
    {
        this.get(page, '#controller#@index');
        this.get('#page#/create', '#controller#@create');
        this.get('#page#/{id}', '#controller#@show');
        this.get('#page#/{id}/edit', '#controller#@edit');
        
        this.post(page, '#controller#@store');
        this.post('#page#/{id}', '#controller#@update');
        this.post('#page#/{id}/delete', '#controller#@delete');

        var controllerPath = getBaseDir('/App/Controllers/#controller#.cfc');

        if (!fileExists(controllerPath)) {
            saveContent variable = "templateContent" {
                include "ResourceTemplate.cfm";
            }

            fileWrite(controllerPath, templateContent);
        }
    }

    /**
     * Finds the given URI in the request routes.
     *
     * @return any
     */
    public any function findURI(required string uri)
    {
        var routeURI = [];

        for (route in request.routes) {
            if (lCase(route.getType()) == lCase(cgi.request_method)) {
                var vars = this.extractVars(route.getURI());
                var keys = listToArray(lCase(stripSlashes(uri)), '/');
                var page = (arrayLen(keys) >= 1) ? keys[1] : '';
                var params = {};

                // Remove first key that indicates page
                if (arrayLen(keys) >= 1) {
                    arrayDeleteAt(keys, 1);
                }

                for (var v = 1; v <= arrayLen(vars); v++) {
                    if (arrayIsDefined(keys, v)) {
                        structInsert(params, vars[v], val(keys[v]));
                    }
                }

                if (lCase(route.getPage()) == lCase(page)) {
                    routeURI = route;
                    routeURI.params = params;
                    break;
                }
            }
        }

        if (isArray(routeURI) && stripSlashes(uri) != '' && !arrayContains(this.ignore, uri) && !arrayContains(this.ignoreExtensions, listLast(uri, '.'))) {
            throw(message = "Route directive for page '#uri#' using method #cgi.request_method# does not exist.");
        }

        return routeURI;
    }

    /**
     * Extracts variables from a URI.
     *
     * @return any
     */
    public any function extractVars(required string uri)
    {
        var items = listToArray(uri, '/');
        var result = [];

        for (i in items) {
            if (startsWith(i, '{') && endsWith(i, '}')) {
                var key = left(i, len(i) - 1);
                key = right(key, len(key) - 1);
                arrayAppend(result, key);
            }
        }

        return result;
    }
}
