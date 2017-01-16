component
{
    /**
     * Constructor method for auth.
     *
     * @return any
     */
    public any function init()
    {
        return this;
    }

    /**
     * Returns the authenticated user.
     *
     * @return any
     */
    public any function user()
    {
        return session.auth;
    }

    /**
     * Checks whether the web user is a guest (unauthenticated).
     *
     * @return any
     */
    public any function guest()
    {
        return structIsEmpty(session.auth);
    }

    /**
     * Handles user login through the auth controller.
     *
     * @return any
     */
    public any function login(any targetUser = {})
    {
        var userRecord = new App.Controllers.AuthController().login(this.token(), targetUser);
        session.auth = userRecord;
    }

    /**
     * Gets the token from cookie or a new one.
     *
     * @return string
     */
    public string function token()
    {
        return (structKeyExists(cookie, 'cfuser')) ? cookie.cfuser : lCase(createUUID());
    }
}
