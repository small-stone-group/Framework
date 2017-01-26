component
{
    /**
     * Redirects to the given URL.
     *
     * @return any
     */
    public any function to(string path = '/')
    {
        if (startsWith(path, 'http')) {
            location(path, false);
        } else {
            location(getUrl(path), false);
        }
    }

    /**
     * Redirects to the previous page.
     *
     * @return any
     */
    public any function back()
    {
        location(session.redirect.previous, false);
    }
}
