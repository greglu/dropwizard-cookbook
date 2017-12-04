# dropwizard Cookbook CHANGELOG

This file is used to list changes made in each version of the dropwizard cookbook.

## 2.0.0 (2017-12-05)

Big thanks to [caramcc](https://github.com/caramcc) for her work on this release.

- Integrated `pleaserun` gem for init script creation. The `dropwizard` resource should now theoretically support any platform that the gem supports.
- Updated for compatibility with Chef 13.
- Updated various gems.
- Updated dropwizard resource to use Chef's 12.5 custom resource DSL.
- Updated test-kitchen version and usage.
  - Using InSpec for test-kitchen verification.
  - Expanded platforms to `ubuntu-14.04`, `ubuntu-16.04`, `centos-6`, and `centos-7`.
- Removed pleaserun cookbook dependency.
  - Created the `dropwizard_pleaserun` custom resource that wraps the gem. Improves upon the community cookbook by fixing bugs, adding in missing functionality, and maintains compatibility.
- Added `safe_restart` feature.
- Added `log_directory` and `init_platform` properties to dropwizard resource.

### Breaking Changes

- Removed properties: `pid_path`, `init_script_source`, and `init_script_cookbook` since they're now managed by `pleaserun`.
