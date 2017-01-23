component
{
    /**
     * Constructor method for media.
     *
     * @return any
     */
    public any function init(string file = '')
    {
        if (file != '' && fileExists(file)) {
            this.file = file;
        }

        return this;
    }

    /**
     * Uploads the given form field to the given relative data path;
     *
     * @return any
     */
    public any function upload(required string field, required string path, string accept = '')
    {
        if (!structKeyExists(form, field)) {
            throw("Form field '#field#' does not exist.");
            return this;
        }

        var file = fileUpload(
            getDataDir(path, true),
            field,
            accept,
            'makeUnique',
            false
        );

        this.file = '#file.serverDirectory#/#file.serverFile#';

        return this;
    }

    /**
     * Renames the file.
     * If no new name is given, a random UID is used.
     *
     * @return any
     */
    public any function rename(string name = '')
    {
        if (name == '') {
            name = lCase(createUUID());
        }

        var extension = listLast(this.file, '.');
        var dir = listToArray(this.file, '/');
        arrayDeleteAt(dir, arrayLen(dir));

        var newPath = '#arrayToList(dir, "/")#/#name#.#extension#';

        fileMove(
            this.file,
            newPath
        );

        this.file = newPath;

        return this;
    }

    /**
     * Gets the name of the file.
     *
     * @return string
     */
    public string function name()
    {
        var file = listLast(this.file, '/');
        return listFirst(file, '.');
    }

    /**
     * Gets the URL of the file.
     *
     * @return string
     */
    public string function url(any size = '')
    {
        if (isValid('string', size) && size != '') {
            // Get size from environment
        } else if (isValid('numeric', size) && size > 0) {
            // Use dynamic size
        }

        var cutoff = len(getDataDir());
        var uri = stripSlashes(mid(this.file, cutoff, len(this.file) - cutoff));
        return getUrl('/data/#uri#');
    }
}
