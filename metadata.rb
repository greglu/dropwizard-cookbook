# encoding: UTF-8

name             'dropwizard'
maintainer       'Gregory Lu'
maintainer_email 'greg.lu@gmail.com'
license          'Apache 2.0'
description      'LWRP for dropwizard applications'
long_description 'Check out the [GitHub docs]' +
                 '(https://github.com/greglu/dropwizard-cookbook) ' +
                 'for more information.'
version          '1.0.2'

depends 'apt'
depends 'java'

%w{ ubuntu centos }.each do |os|
  supports os
end
