component
{
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
    public any function handle()
    {
        if (structKeyExists(url, "controller") && structKeyExists(url, "method")) {
            var component = createObject("component", "App.Controllers.#url.controller#");
            var method = component.getMethod(url.method);
            method(form);
            return this;
        }

        try {
            if (structKeyExists(url, 'url_payload')) {
                route().findURI(url.url_payload).perform();
            }
        } catch (any error) {
            writeDump(error);
            return this;
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
     * Finds the given URI in the request routes.
     *
     * @return any
     */
    public any function findURI(required string uri)
    {
        var routeURI = [];

        for (route in request.routes) {
            if (
                lCase(stripSlashes(route.getURI())) == lCase(stripSlashes(uri)) &&
                lCase(route.getType()) == lCase(cgi.request_method)
            ) {
                routeURI = route;
                break;
            }
        }

        if (isArray(routeURI)) {
            throw(message = "Route directive for page '#uri#' using method #cgi.request_method# does not exist.");
        }

        return routeURI;
    }
}
