component
{
    variables.from = application.mvc.mail.from;
    variables.server = application.mvc.mail.server;
    variables.username = application.mvc.mail.username;
    variables.password = application.mvc.mail.password;

    variables.instance.subject = '';
    variables.instance.recipient = '';
    variables.instance.content = '';
    variables.instance.contentArgs = {};

    /**
     * Constructor method for mail.
     *
     * @return any
     */
    public any function init()
    {
        return this;
    }

    /**
     * Set the subject of the email.
     *
     * @return any
     */
    public any function subject(required string text)
    {
        variables.instance.subject = text;
        return this;
    }

    /**
     * Set the content of the email.
     * Must use the name of a view.
     *
     * @return any
     */
    public any function content(required string viewName, struct args = {})
    {
        variables.instance.content = viewName;
        variables.instance.contentArgs = args;
        return this;
    }

    /**
     * Set the recipient of the email.
     *
     * @return any
     */
    public any function to(required string recipient)
    {
        variables.instance.recipient = recipient;
        return this;
    }

    /**
     * Sends the email.
     *
     * @return void
     */
    public void function send()
    {
        var post = new mail();

        saveContent variable = 'postContent' {
            view(variables.instance.content, variables.instance.contentArgs);
        }

        post.setTo(variables.instance.recipient);
        post.setFrom(variables.from);
        post.setSubject(variables.instance.subject);
        post.setType('html');
        post.setAttributes(
            server = variables.server,
            username = variables.username,
            password = variables.password
        );

        post.send(body = postContent);
    }
}
