component
{
    // Boot the framework facades
    new App.Framework.Boot();

    /**
     * Handles the application startup.
     *
     * @return any
     */
    public any function onApplicationStart()
    {
        // Load the config into application
        var config = (fileExists(getBaseDir('app.json'))) ? deserializeJSON(fileRead(getBaseDir('app.json'))) : {};

        for (key in config) {
            application[key] = config[key];
        }
    }

    /**
     * Handles the start of a request.
     *
     * @return void
     */
    public void function onRequestStart()
    {
        // Add the web routes
        new web();

        request.start = getTickCount();
        session.redirect.current = cgi.http_referer;
    }

    /**
     * Handles the request.
     * Called after onRequestStart.
     *
     * @return any
     */
    public any function onRequest(required string thePage)
    {
        if (!structFindDefault(application.mvc, 'production', true)) {
            onApplicationStart();
            auth().refresh();
        }

        // Handle the request
        route().handle(thePage);
    }

    /**
     * Handles the end of a request.
     *
     * @return void
     */
    public void function onRequestEnd()
    {
        request.end = getTickCount();
        request.duration = request.end - request.start;

        // Write debug info if not in production environment
        if (!structFindDefault(application.mvc, 'production', true)) {
            writeOutput('<div class="container pt-5 pb-5 text-muted">Execution Time: #request.duration#ms</div>');
        }

        session.redirect.previous = structFindDefault(session.redirect, 'current', getUrl());
    }

    /**
     * Handles the start of a session.
     *
     * @return any
     */
    public any function onSessionStart()
    {
        // Attempt to login the user
        auth().login();

        session.redirect = {};
    }

    /**
     * Handles any uncaught exception.
     *
     * @return any
     */
    public any function onError(any exception)
    {
        writeDumpToFile(exception);
    }
}
