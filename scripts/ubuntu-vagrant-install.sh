#!/bin/bash

VAGRANT_FILENAME="vagrant_1.3.5_x86_64.deb"
VAGRANT_DOWNLOAD="http://files.vagrantup.com/packages/a40522f5fabccb9ddabad03d836e120ff5d14093/vagrant_1.3.5_x86_64.deb"
VAGRANT_SHA1SUM="68e1f2f9c4f6a978ede4a18657c261d346e63225  vagrant_1.3.5_x86_64.deb"

CODENAME=`lsb_release -c | grep -o "\w*$"`

echo "deb http://download.virtualbox.org/virtualbox/debian $CODENAME contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -

sudo apt-get update
sudo apt-get -y install virtualbox-4.3

wget "$VAGRANT_DOWNLOAD"
echo "$VAGRANT_SHA1SUM" | sha1sum -c -
if [ $? != 0 ]; then
  echo "File downloaded from:"
  echo "  $VAGRANT_DOWNLOAD"
  echo "does not match checksum:"
  echo "  $VAGRANT_SHA1SUM"
fi

sudo dpkg -i "$VAGRANT_FILENAME"
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
