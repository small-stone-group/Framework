component
{
    // Boot the framework facades
    new App.Framework.Boot();

    /**
     * Handles the start of a request.
     *
     * @return void
     */
    public void function onRequestStart()
    {
        // Run the web routes
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
        // Handle the request
        route().handle(thePage);
    }
}
