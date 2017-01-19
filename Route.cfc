component
{
    this.ignore = [];
    this.ignoreExtensions = ['.cfm', '.cfml', 'html', 'htm', 'ico'];
    this.currentMiddleware = '';

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
            r.checkMiddleware().perform(r.params);
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
        var routeURI = new App.Framework.RouteURI('get', uri, action, this.currentMiddleware);
        arrayAppend(request.routes, routeURI);
        return this;
    }

    /**
     * Adds a POST HTTP request to the pool.
     *
     * @return any
     */
    public any function post(required string uri, required string action)
    {
        var routeURI = new App.Framework.RouteURI('post', uri, action, this.currentMiddleware);
        arrayAppend(request.routes, routeURI);
        return this;
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
     * Constructs a middleware group.
     *
     * @return any
     */
    public any function middleware(required string name)
    {
        this.currentMiddleware = name;
        return this;
    }

    /**
     * Finds the given URI in the request routes.
     *
     * @return any
     */
    public any function findURI(required string uri)
    {
        var routeURI = [];
        var searchType = lCase(cgi.request_method);
        var searchPath = lCase(stripSlashes(uri));
        var searchPage = listFirst(searchPath, '/');
        var searchKeys = listToArray(searchPath, '/');

        for (route in request.routes) {
            if (lCase(route.getType()) == searchType) {
                var routeStr = lCase(stripSlashes(route.getURI()));
                var routeKeys = listToArray(routeStr, '/');
                var keyIndex = 1;
                var ignore = false;
                var keep = false;
                var params = {};

                if (arrayIsEmpty(routeKeys) && arrayIsEmpty(searchKeys)) {
                    routeURI = route;
                    routeURI.params = params;
                    break;
                }

                if (!arrayIsEmpty(searchKeys)) {
                    for (key in searchKeys) {
                        if (arrayIsDefined(routeKeys, keyIndex)) {
                            var routeSegment = routeKeys[keyIndex];

                            if (startsWith(routeSegment, '{') && endsWith(routeSegment, '}')) {
                                var rsKey = left(routeSegment, len(routeSegment) - 1);
                                rsKey = right(rsKey, len(rsKey) - 1);
                                structInsert(params, rsKey, key);
                                routeURI = route;
                                routeURI.params = params;
                            } else {
                                if (routeSegment == key && arrayLen(searchKeys) == arrayLen(routeKeys)) {
                                    routeURI = route;
                                    routeURI.params = params;
                                    keep = true;
                                } else {
                                    ignore = true;
                                    break;
                                }
                            }
                        } else {
                            ignore = true;
                            break;
                        }

                        keyIndex++;
                    }
                }

                if (keep) {
                    break;
                }

                if (ignore) {
                    continue;
                }
            }
        }

        if (
            isArray(routeURI) &&
            searchPath != '' &&
            !arrayContains(this.ignore, uri) &&
            !arrayContains(this.ignoreExtensions, listLast(uri, '.'))
        ) {
            view('layouts.index|errors.404', {
                'title' = 'Page not found',
                'nav' = false,
                'message' = "Route directive for page '#uri#' using method #cgi.request_method# does not exist."
            });

            abort;
        }

        return routeURI;
    }
}
