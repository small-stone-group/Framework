component
{
    variables.instance.type = "";
    variables.instance.uri = "";
    variables.instance.action = "";

    /**
     * Constructor function for the component.
     *
     * @return any
     */
    public any function init(required string type, required string uri, required string action)
    {
        variables.instance.type = type;
        variables.instance.uri = uri;
        variables.instance.action = action;
        return this;
    }

    /**
     * Gets the page from the URI.
     *
     * @return string
     */
    public string function getPage()
    {
        return listFirst(stripSlashes(variables.instance.uri), '/');
    }

    /**
     * Gets the raw URI.
     *
     * @return string
     */
    public string function getURI()
    {
        return variables.instance.uri;
    }

    /**
     * Gets the type.
     *
     * @return string
     */
    public string function getType()
    {
        return variables.instance.type;
    }

    /**
     * Gets the raw action.
     *
     * @return string
     */
    public string function getAction()
    {
        return variables.instance.action;
    }

    /**
     * Performs the route action.
     *
     * @return any
     */
    public any function perform(struct params = {})
    {
        var action = this.getAction();

        if (endsWith(action, ['.cfm', '.cfml', 'html', 'htm', 'ico'])) {
            // Include file
            saveContent variable = "routeContent" {
                for (p in params) {
                    setVariable(p, params[p]);
                }

                include '../../#action#';
            }

            writeOutput(routeContent);
        } else {
            // Plain text
            var controller = listFirst(action, '@');
            if (fileExists(getBaseDir('App/Controllers/#controller#.cfc'))) {
                var component = createObject("component", "App.Controllers.#controller#");
                var method = component.getMethod(listLast(action, '@'));
                method(params);
            } else {
                var viewFile = view().getFile(action);
                if (fileExists(viewFile)) {
                    view(action, params);
                } else {
                    writeOutput(action);
                }
            }
        }

        return this;
    }
}
