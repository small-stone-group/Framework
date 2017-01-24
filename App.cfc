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
     * Handles the start of a session.
     *
     * @return any
     */
    public any function onSessionStart()
    {
        // Attempt to login the user
        auth().login();
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
