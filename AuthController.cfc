component extends = "Controller"
{
    public any function init(string token = '')
    {
        if (token != '') {
            var authModel = createObject('component', 'App.#this.authModel#').init();
            var tokenRecord = new Token().where('uid', token).take(1).getArray();

            if (arrayIsEmpty(tokenRecord)) {
                
            } else {

            }
        }
    }
}
