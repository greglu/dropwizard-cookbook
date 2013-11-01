# dropwizard cookbook

Exposes an LWRP for managing [dropwizard](http://dropwizard.codahale.com/) applications.

[![Build Status](https://api.travis-ci.org/greglu/dropwizard-cookbook.png)](https://travis-ci.org/greglu/dropwizard-cookbook)


## Requirements

* [java cookbook](https://github.com/opscode-cookbooks/java)
* [apt cookbook](https://github.com/opscode-cookbooks/apt)


## Supported Platforms

Creates an [upstart](http://en.wikipedia.org/wiki/Upstart#Adoption) init script, so this will work for any OS that supports it, including Ubuntu and CentOS. Will look at expanding to more platforms later.


## Resources and Provider Usage

### `dropwizard` resource

#### attributes

|attribute|required|default|description|
|---------|--------|-------|-----------|
|name|**true**||Name of the application. Implied from resource name.|
|path|false|/opt/[name]|Path for the application. Will default into /opt with the application name.|
|user|**true**||System user for running the application.|
|group|false||System group for running the application.|
|jar_file|false|/opt/[name]/[name].jar|Path to your dropwizard application's [fat JAR](http://dropwizard.codahale.com/getting-started/#building-fat-jars) file. It will look into a default path if this isn't set. The default path can be a symlink to your real JAR file, but will depend on your release process.|
|java_bin|false|Output of `which java` or `/usr/bin/java`|Specific `java` command for running the application. Should be set as `#{node[:java][:home]}/bin/java` when using the [java cookbook](https://github.com/opscode-cookbooks/java).|
|jvm_options|false||JVM options with which to start the dropwizard application. Although there are none set by default, it's highly recommended that you at least set the `-Xms` and `-Xmx` parameters here for defining the Java heap size.|
|arguments|false|server|Arguments to pass after the jar file inclusion. See [Running Your Service](http://dropwizard.codahale.com/getting-started/#running-your-service) in the dropwizard docs for more info. This is where you'd also want to include your YAML config file (don't forget to add `server`!).|
|pid_path|false|/var/run|Directory in which the PID file should be created. By default, creates the file as: `/var/run/[name].pid`|
|init_script_source|false|dropwizard-init.conf.erb|Source template file for which init script to use. Will using this cookbook's [template file](https://github.com/greglu/dropwizard-cookbook/blob/master/templates/default/dropwizard-init.conf.erb) by default, but can be replaced with your own.|
|init_script_source|false|dropwizard|If you change the `init_script_source` attribute, you'll also need to override this one with the name of your own cookbook.|

#### `:install` action

Creates application user, directories, init scripts, and service for the dropwizard application. Check out the `Examples` section of this README for more information.

#### `:delete` action

Removes the directories, init scripts and service for the dropwizard application. Will leave the user intact, though.


#### `:disable` action

Disables and stops the dropwizard application service, but makes no other changes


## Examples

Check out this project's `test/cookbooks/dw_test` directory for an example recipe.

1) Most basic example:

```ruby
dropwizard "application_name" do
  user "app_user"
end
```

2) Including a dropwizard config and a few other options:

```ruby
dropwizard node[:your_app][:name] do
  user "app_user"
  java_bin "#{node[:java][:home]}/bin/java"
  jvm_options "-Xms1g -Xmx1g"
  arguments "server #{node[:your_app][:config]}"
end

template node[:your_app][:config] do
  source 'your_app-config.yml.erb'
  mode 0644
  owner node[:your_app][:user]
  group node[:your_app][:group]

  subscribes :create, "dropwizard[#{node[:your_app][:name]}]", :delayed
end
```

## Running Tests

Running basic knife tests, foodcritic, chefspec, and rubocop can be done with:

```
$ bundle install
$ rake
```

[test-kitchen](https://github.com/opscode/test-kitchen) is also used, and can be run with:

```
$ kitchen test
```

To use test-kitchen, make sure you go through the [Getting started](https://github.com/opscode/test-kitchen#getting-started) instructions first if you haven't done so already.


## License

    Copyright 2013 Greg Lu

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

