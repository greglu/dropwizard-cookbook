# Testing

Testing of this cookbook is done with the following tools:

* [ChefSpec](https://chefspec.github.io/chefspec/)
* [Test Kitchen](http://kitchen.ci/)
* [Foodcritic](http://www.foodcritic.io/)
* [RuboCop](https://github.com/bbatsov/rubocop)
* [InSpec](https://www.inspec.io/)

## Prerequisites

* [ChefDK](https://docs.chef.io/install_dk.html)
* [Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/)

## Unit Tests

The default rake task will run foodcritic, chefspec, and rubocop:

```
bundle install
bundle exec berks
bundle exec rake
```

## Integration Tests

These will run against multiple platforms listed in `.kitchen.yml` and use `InSpec` for verification.

```
kitchen test
```
