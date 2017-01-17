component
{
    public any function to(string path = '/')
    {
        if (startsWith(path, 'http')) {
            location(path, false);
        } else {
            location(getUrl(path), false);
        }
    }
}
