component extends = "Controller"
{
    /**
     * Constructor method for AuthController.
     *
     * @return any
     */
    public any function init()
    {
        return this;
    }

    /**
     * Attempts to login the user using the given token.
     *
     * @return any
     */
    public any function login(string token = '', any targetUser = {})
    {
        if (token != '') {
            var authModel = this.model();
            var tokenRecord = new App.Framework.Token()
                .where('token', token)
                .take(1)
                .getArray();

            if (arrayIsEmpty(tokenRecord)) {
                if (!structIsEmpty(targetUser)) {
                    var newToken = new App.Framework.Token().save({'token' = token});
                    targetUser.remember_token = newToken.id;
                    targetUser.save();
                    cookie.cfuser = token;
                } else {
                    return {};
                }
            } else {
                tokenRecord = tokenRecord[1];
                var user = authModel
                    .where('remember_token', tokenRecord.id)
                    .take(1)
                    .getArray();

                if (arrayIsEmpty(user)) {
                    return {};
                } else {
                    return user[1];
                }
            }
        }
    }
}
