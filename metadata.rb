# frozen_string_literal: true

name 'dropwizard'
version '2.0.0'

maintainer 'Gregory Lu'
maintainer_email 'greg.lu@gmail.com'
description 'Custom resource for managing dropwizard applications'
long_description 'Check out the [GitHub docs](https://github.com/greglu/dropwizard-cookbook) ' \
                 'for more information.'
source_url 'https://github.com/greglu/dropwizard-cookbook'
issues_url 'https://github.com/greglu/dropwizard-cookbook/issues'
license 'Apache-2.0'

chef_version '>= 12.5.0' if respond_to?(:chef_version)

%w[amazon centos debian fedora ubuntu].each do |os|
  supports os
end
