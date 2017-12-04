# sample-app

This is a sample application used for testing purposes. It mimics a dropwizard application by creating a fat JAR (deployable in a similar fashion) that reads in a YAML configuration file, and serves HTTP requests by responding with attributes from the config file.

This is using [nanohttpd](https://github.com/NanoHttpd/nanohttpd) instead of the actual dropwizard framework because of size differences in the generated fat JAR, i.e. ~30K vs 8MB for a bare dropwizard app.


## Usage

```
mvn clean package
```

should create the JAR file: `target/helloworld-1.0.0.jar`.

### Hard-coded message

The JAR file can be run with the following commands, which will create an HTTP server, bound to port 8080:

```
java -jar target/helloworld-1.0.0.jar server
```

Running `curl http://localhost:8080` will return the message `hello world`.

### Custom message

Starting the server with:

```
java -jar target/helloworld-1.0.0.jar server config.yml
```

and config.yml:

```
message: any message you want
```

Will have `curl http://localhost:8080` return your custom message: `any message you want`.

### Config Check

If there's a line in `config.yml` with the following:

```
check: false # true or false
```

running the command:

```
java -jar target/helloworld-1.0.0.jar check config.yml
```

will return an exit code of 0 (if `true`) or 1 (if `false`).

## Example

This is used as part of the `dw_test` cookbook whose JAR file can be found in `test/cookbooks/dw_test/files/default/dw_test.jar`.
