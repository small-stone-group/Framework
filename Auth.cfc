component
{
    /**
     * Handles user login through the auth controller.
     *
     * @return any
     */
    public any function login()
    {
        var token = lCase(createUUID());

        if (structKeyExists(cookie, 'cfuser')) {
            token = cookie.cfuser;
        }

        new App.Controllers.AuthController(token);
    }
}
