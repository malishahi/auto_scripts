














exit 0
#git clone git@github.com:cloudfoundry-community/bosh-bootstrap.git
git clone https://github.com/cloudfoundry-community/bosh-bootstrap.git
cd bosh-bootstrap
bundle install
./bin/bosh-bootstrap deploy
