sudo apt-get install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev
sudo gem install bosh_cli bosh_cli_plugin_micro --no-ri --no-rdoc

echo 2. Install Vagrant 

echo Get it from http://www.vagrantup.com/downloads.html, and install it.
read
sudo dpkg --install vagrant_1.7.2_x86_64.deb
vagrant --version

echo 3. BOSH-LITE installation

mkdir ~/git
git clone https://github.com/cloudfoundry/bosh-lite

echo 4. Install Virtualbox

wget http://download.virtualbox.org/virtualbox/4.3.28/virtualbox-4.3_4.3.28-100309~Ubuntu~raring_amd64.deb
sudo dpkg --install virtualbox-4.3_4.3.28-100309~Ubuntu~raring_amd64.deb
VBoxManage --version

echo 5. Start Vagrant from the base directory of this repository

vagrant up --provider=virtualbox

echo 6. Initialize BOSH-LITE configuration

bosh target 192.168.50.4 lite

bosh login
bin/add-route
echo 8. Install CloudFoundry

echo 8.1. Install Spiff

echo Download the latest binary of Spiff from https://github.com/cloudfoundry-incubator/spiff/releases. Then, extract it into your local binary file directory.

sudo unzip spiff_linux_amd64.zip -d /usr/local/bin

echo 8.2. Clone CloudFoundry and provision it

git clone https://github.com/cloudfoundry/cf-release
./bin/provision_cf

echo 9. Prepare Cloud Foundry deployment

echo Install the Cloud Foundry CLI and run the following:

echo Download CF client for your Operating System https://github.com/cloudfoundry/cli#downloads, and install it.

cf api --skip-ssl-validation https://api.10.244.0.34.xip.io
cf auth admin admin
cf create-org  DC4Cities
cf target -o DC4Cities
cf create-space TrentoTrial
cf target -s TrentoTrial

cf push frontend -n frontend -k 100M -m 128M
cf push elaboration -n elaboration -k 100M -m 128M
cf push backend -n backend -k 100M -m 128M

Reference on CF for more info: https://github.com/cloudfoundry/bosh-lite/blob/master/docs/deploy-cf.md


11. Clone EASC branch named easc-cf from the git repository, and build the EASC system


   ```
  $cd ~/git/easc
  $git clone ..
  $mvn clean install -DskipTests
   ```

12. Run EASC-CFApp instance

   ```
  $cd ~/git/easc/EASC-CFApp
  $bin/EASC.sh
   ```

If there is no problem, EASC should be waiting to receive activity plans for execution.

13. Prepare Activity Plan and Send it to CloudFoundry type of EASC

Edit dateFrom and dateTo (inside AP2.json) to be ahead of time, better very close to the current time to start EASC earlier for you, and to see WM changes by EASC and scaling operation by CloudFoundry. 

You can see the WM definitions in AppConfig.yaml.

   ```
  $cd ~/git/easc/EASC-CFApp/resources
  $vim AP2.json
  $./injectActivityPlan.sh

   ```

If there is no problem, EASC service should schedule the activity plan execution, and you will see the scheduling time in the EASC output.

Then, as it enacts different working mode, you should see how EASC-CloudFoundry applications scaling, starting, stoping applications, etc. It will also print out some monitoring information on applications containers.

14. That's it.
