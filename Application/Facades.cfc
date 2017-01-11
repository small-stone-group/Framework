component
{
    /**
     * Returns a new route object.
     *
     * @return route
     */
    public any function route(string controller = '', string method = '')
    {
        return new App.Framework.Route(controller, method);
    }

    /**
     * Returns a new view object.
     *
     * @return view
     */
    public any function view(required string name, struct args = {})
    {
        return new App.Framework.View(name, args);
    }

    /**
     * Returns a new query builder object.
     *
     * @return queryBuilder
     */
    public any function queryBuilder(string datasource = "")
    {
        return new App.Framework.QueryBuilder(datasource);
    }

    /**
     * Returns a new schema object.
     *
     * @return schema
     */
    public any function schema(required string table, string datasource = "")
    {
        return new App.Framework.Schema(table, datasource);
    }

    /**
     * Returns a new validate object.
     *
     * @return validate
     */
    public any function validate(required struct data, required struct rules)
    {
        return new App.Framework.Validate(data, rules);
    }

    /**
     * Returns the user object in the session.
     *
     * @return user
     */
    public any function user()
    {
        return session.user;
    }

    /**
     * Gets a full URL with the given path.
     *
     * @return string
     */
    public string function getUrl(string uri = '')
    {
        var https = (cgi.https == 'off') ? 'http' : 'https';
        return '#https#://#cgi.server_name#/#stripSlashes(uri)#';
    }

    /**
     * Gets the datasource.
     *
     * @return string
     */
    public string function getDatasource(boolean migration = false)
    {
        if (migration) {
            return application.mvc.migrationDatasource;
        }

        return application.mvc.datasource;
    }

    /**
     * Gets the base directory path (wwwroot).
     *
     * @return string
     */
    public string function getBaseDir(string path = '', boolean create = false)
    {
        var baseDir = application.mvc.baseDirectory;

        if (arrayContains(['/', '\'], right(baseDir, 1))) {
            baseDir = left(baseDir, len(baseDir) - 1);
        }

        var targetDir = '#baseDir#\#path#';

        if (create && !directoryExists(targetDir)) {
            directoryCreate(targetDir);
        }

        return targetDir;
    }

    /**
     * Gets the data directory path.
     *
     * @return string
     */
    public string function getDataDir(string path = '', boolean create = false)
    {
        var dataDir = application.mvc.dataDirectory;

        if (arrayContains(['/', '\'], right(dataDir, 1))) {
            dataDir = left(dataDir, len(dataDir) - 1);
        }

        var targetDir = '#dataDir#\#path#';

        if (create && !directoryExists(targetDir)) {
            directoryCreate(targetDir);
        }

        return targetDir;
    }

    /**
     * Gets the current timestamp.
     *
     * @return string
     */
    public string function getTimestamp()
    {
        return "#dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'HHmmss')#";
    }

    /**
     * Writes the given data to file dump.
     *
     * @return void
     */
    public void function writeDumpToFile(required any data, string file = "")
    {
        file = (len(file)) ? file : "#getDataDir('logs\log-#getTimestamp()#.html')#";
        writeDump(var = data, output = file, format = "html");
    }

    /**
     * Writes the given data to file dump and also dumps it on screen.
     *
     * @return void
     */
    public void function writeDumpToBoth(required any data, string file = "")
    {
        writeDumpToFile(data, file);
        writeDump(data);
    }

    /**
     * Shorthand function for cfcookie.
     *
     * @return void
     */
    public void function cookie(required string name, required string value, required string expires)
    {
        new App.Framework.Legacy().cookie(name, value, expires);
    }

    /**
     * Find key in struct and return value, if not found, return given default.
     *
     * @return any
     */
    public any function structFindDefault(required struct object, required string key, required any defaultValue)
    {
        if (structKeyExists(object, key)) {
            return structFind(object, key);
        } else {
            return defaultValue;
        }
    }

    /**
     * Checks whether the given string ends with the given substring(s).
     *
     * @return boolean
     */
    public boolean function endsWith(required string str, required any substr)
    {
        if (isArray(substr)) {
            for (s in substr) {
                if (right(str, len(s)) == s) {
                    return true;
                }
            }
        } else {
            if (right(str, len(substr)) == substr) {
                return true;
            }
        }

        return false;
    }

    /**
     * Strips leading and trailing slashes.
     *
     * @return any
     */
    public string function stripSlashes(required string str)
    {
        if (left(str, 1) == '/' || left(str, 1) == '\') {
            str = right(str, len(str) - 1);
        }

        if (right(str, 1) == '/' || right(str, 1) == '\') {
            str = left(str, len(str) - 1);
        }

        return str;
    }

    /**
     * Joins a time object to a date object.
     *
     * @return any
     */
    public any function joinTime(required any dateValue, required any timeValue)
    {
        if (isValid("string", dateValue) && len(dateValue) == 0) {
            dateValue = createDate(year(now()), month(now()), day(now()));
        }

        if (isValid("string", timeValue) && len(timeValue) == 0) {
            timeValue = createTime(0, 0, 0);
        }

        return createDateTime(
            year(dateValue),
            month(dateValue),
            day(dateValue),
            hour(timeValue),
            minute(timeValue),
            second(timeValue)
        );
    }

    /**
     * Makes a human readable timestamp from the given datetime object(s).
     * Eg. 12 minutes ago, 1 day ago, 4 weeks ago.
     *
     * @return string
     */
    public string function humanTimeDiff(required any from, any to = {})
    {
        if (isValid("struct", to)) {
            to = now();
        }
     
        var diff = dateDiff("s", from, to);
        var since = 'Just now';
        var sMinute = 60;
        var sHour = 60 * sMinute;
        var sDay = 24 * sHour;
        var sWeek = 7 * sDay;
        var sMonth = 4 * sWeek;
        var sYear = 12 * sMonth;
     
        if (diff < sHour) {
            mins = round(diff / sHour);
            if (mins <= 1) mins = 1;
            since = '#mins# minute';
            if (mins > 1) since &= 's';
        } else if (diff < sDay && diff >= sHour) {
            hours = round(diff / sHour);
            if (hours <= 1) hours = 1;
            since = '#hours# hour';
            if (hours > 1) since &= 's';
        } else if (diff < sWeek && diff >= sDay) {
            days = round(diff / sDay);
            if (days <= 1) days = 1;
            since = '#days# day';
            if (days > 1) since &= 's';
        } else if (diff < sMonth && diff >= sWeek) {
            weeks = round(diff / sWeek);
            since = '#weeks# week';
            if (weeks > 1) since &= 's';
        } else if (diff < sYear && diff >= sMonth) {
            months = round(diff / sMonth);
            if (months <= 1) months = 1;
            since = '#months# month';
            if (months > 1) since &= 's';
        } else if (diff >= sYear) {
            years = round(diff / sYear);
            if (years <= 1) years = 1;
            since = '#years# year';
            if (years > 1) since &= 's';
        }

        return '#since# ago';
    }
}
