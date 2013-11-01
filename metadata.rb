name             'dropwizard'
maintainer       'Gregory Lu'
maintainer_email 'greg.lu@gmail.com'
license          'Apache 2.0'
description      'LWRP for dropwizard applications'
version          '0.0.1'

depends 'apt'
depends 'java'

%w{ ubuntu centos }.each do |os|
  supports os
end
