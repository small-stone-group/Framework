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
}
