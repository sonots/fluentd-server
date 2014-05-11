## API

### GET /api/:name

Get the contents of Fluentd config post whose name is :name. 
Query parameters are replaced with variables in erb. 

Supported query parameter formats are:

* var=value

  * The variable `var` is replaced with its value in erb.

* var[]=value1&var[]=value2

  * Array. The variable `var[idx]` such as `var[0]` and `var[1]` is replaced with its value in erb.

* var[key1]=value1&var[key2]=value2

  * Hash. The variable `var[key]` such as `var[key1]` and `var[key2]` is replaced with its value in erb.

