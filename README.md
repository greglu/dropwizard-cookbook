# dropwizard cookbook

Custom resource for managing [dropwizard](http://www.dropwizard.io/) applications.

[![Build Status](https://travis-ci.org/greglu/dropwizard-cookbook.png?branch=master)](https://travis-ci.org/greglu/dropwizard-cookbook)

## Supported Platforms

This cookbook uses the `pleaserun` [gem](https://github.com/jordansissel/pleaserun) to auto-detect and generate init scripts. Theoretically any platform supported by the gem is supported by this cookbook.

### Known Issues

* CentOS 6 seems to have an issue where `pleaserun` generates upstart scripts but the chef `service` resource doesn't pick them up. To work around this issue, set `init_platform` to `sysv` on the dropwizard resource.

## Resources

### `dropwizard` resource

#### properties

|property|required|default|description|
|---------|--------|-------|-----------|
|name|**true**||Name of the application. Implied from resource name.|
|path|false|/opt/[name]|Path for the application. Will default into /opt with the application name.|
|user|**true**||System user for running the application. This resource will manage this user.|
|group|false||System group for running the application.|
|jar_file|false|/opt/[name]/[name].jar|Path to your dropwizard application's [fat JAR](http://dropwizard.codahale.com/getting-started/#building-fat-jars) file. It will look into a default path if this isn't set. The default path can be a symlink to your real JAR file, but will depend on your release process. If the JAR file isn't present, then this resource will not manage the service, only create the init scripts.|
|config_file|false||Path to the dropwizard configuration file. This is required for `safe_restart` to work, otherwise it will perform regular restarts.|
|java_bin|false|Output of `which java` or `/usr/bin/java`|Specific `java` command for running the application. Should be set as `#{node['java']['home']}/bin/java` when using the [java cookbook](https://github.com/opscode-cookbooks/java).|
|jvm_options|false||JVM options with which to start the dropwizard application. Although there are none set by default, it's highly recommended that you at least set the `-Xms` and `-Xmx` parameters here for defining the Java heap size.|
|arguments|false|server|Arguments to pass after the jar file inclusion. See [Running Your Service](http://dropwizard.codahale.com/getting-started/#running-your-service) in the dropwizard docs for more info (don't forget to add `server`!). **Note regarding previous version usage: you can omit the config file path from this property and add it to `config_file` instead.** |
|log_directory|false||Defines a log directory to pass to the `pleaserun` gem. **Note:** not all platforms support this property, so check the [pleaserun gem](https://github.com/jordansissel/pleaserun) for your specific platform.|
|safe_restart|false|false|Performs a "safe" restart if the configuration validates correctly. See the **Safe Restart** section below.|
|init_platform|false||Sets the init platform for the `pleaserun` gem. Leave this blank to have the gem auto-detect.|

#### `:install` action

Creates application user, directories, init scripts, and service for the dropwizard application. Check out the `Examples` section of this README for more information.

#### `:restart` action

Restarts the dropwizard application service. This can run in normal or `Safe Restart` mode (see section below).

#### `:disable` action

Disables and stops the dropwizard application service, but makes no other changes.

#### `:delete` action

Removes the directories, init scripts and service for the dropwizard application. Will leave the user intact, though.

## Examples

Check out this project's `test/cookbooks/dw_test` directory for an example recipe.

1) Most basic example:

    ```ruby
    dropwizard 'application_name' do
      user 'app_user'
    end
    ```

    This example will:
    * Create the `app_user` system user with no login or home directory.
    * Create the `/opt/application_name` directory, owned by `app_user`.
    * Create the init scripts (platform dependent) for `application_name` service.
    * Not start or enable the `application_name` service since the jar won't be present yet. Don't forget to notify `dropwizard[application_name]` if this jar ends up being managed by chef as well.

2) Including a dropwizard config and a few other options:

    ```ruby
    dropwizard node['your_app']['name'] do
      user 'app_user'
      java_bin "#{node['java']['home']}/bin/java"
      jvm_options '-Xms1g -Xmx1g'
      config_file node['your_app']['config']
    end

    template node['your_app']['config'] do
      source 'your_app-config.yml.erb'
      mode 0644
      owner node['your_app']['user']
      group node['your_app']['group']

      notifies :restart, "dropwizard[#{node['your_app']['name']}]", :delayed
    end
    ```

    **Note:** It's recommended to restart the service by notifying the `dropwizard` instead of directly declaring and using the `service` resource in your recipes. It will handle the `safe_restart` functionality, if configured.

## Safe Restart

Dropwizard has a built-in [check command](https://github.com/dropwizard/dropwizard/blob/master/dropwizard-core/src/main/java/io/dropwizard/cli/CheckCommand.java) for verifying compatibility between a JAR and configuration file. Setting `safe_restart` to true will have the `dropwizard` resource check for compatibility before restarting the service. This prevent restarts from occurring that would cause the service to not come back up.

The safe restart feature will also retry restarts on subsequent chef runs, by checking for the existence of a restart flag (which will get deleted when a restart is successful).
