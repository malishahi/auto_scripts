# EASC CloudFoundry demo

This documentation describes the steps to run a demo on the integration of EASC with CloudFoundry through a multi-tier application. First, we describe how to install bosh-lite to run a lightweight CloudFoundry. Then, we describe how to get the right EASC branch from the git that has been developed for this demo. As the technologies behind CloudFoundry and BOSH are evolving we don't provide a script, since most probably the script will fail. We have written the full steps explaining about commands also.

## BOSH-LITE and CloudFoundry Installation

1. Install latest version of bosh_cli by installing the following packages:

   ```
$sudo apt-get install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev
$sudo gem install bosh_cli bosh_cli_plugin_micro --no-ri --no-rdoc
   ```
2. Install Vagrant 

Get it from http://www.vagrantup.com/downloads.html, and install it.

   ```
$sudo dpkg --install vagrant_1.7.2_x86_64.deb
   ```
Known working version:

   ```
$ vagrant --version
Vagrant 1.6.3
   ```

3. BOSH-LITE installation

Clone this repository.

   ```
$cd ~/workspace
$git clone https://github.com/cloudfoundry/bosh-lite

   ```
4. Install Virtualbox

Get it from http://download.virtualbox.org/virtualbox/4.3.28/virtualbox-4.3_4.3.28-100309~Ubuntu~raring_amd64.deb (if this link still works), and install it.

Known working version:
   ```
 $ VBoxManage --version
 4.3.14r95030
   ```
VMware also is supported by Vagrant.

5. Start Vagrant from the base directory of this repository

This directory, e.g. ~/git/bosh-lite, contains the Vagrantfile.

   ```
$vagrant up --provider=virtualbox
   ```

The most recent version of the BOSH Lite boxes will be downloaded by default from the Vagrant Cloud when you run `vagrant up`. If you have already downloaded an older version you will be warned that your version is out of date. You can use the latest version by running `vagrant box update`.

6. Initialize BOSH-LITE configuration

   ```
$bosh target 192.168.50.4 lite
Target set to `Bosh Lite Director'

$bosh login
Your username: admin
Enter password: admin
Logged in as `admin'
   ```
7. Networking
Add a set of route entries to your local route table to enable direct Warden container access every time your networking gets reset (e.g. reboot or connect to a different network). Your sudo password may be required.

 ```
$bin/add-route

 ```


Notes: The local VMs (virtualbox, vmware providers) will be accessible at 192.168.50.4. To change this IP, uncomment the private_network line in the appropriate provider and change the IP address.

   ```
  config.vm.provider :virtualbox do |v, override|
    # To use a different IP address for the bosh-lite director, uncomment this line:
    # override.vm.network :private_network, ip: '192.168.59.4', id: :local
  end


   ```
8. Install CloudFoundry

8.1. Install Spiff

Download the latest binary of Spiff from https://github.com/cloudfoundry-incubator/spiff/releases. Then, extract it into your local binary file directory.

   ```
$sudo unzip spiff_linux_amd64.zip -d /usr/local/bin

   ```

8.2. Clone CloudFoundry and provision it

   ```
$git clone https://github.com/cloudfoundry/cf-release
$./bin/provision_cf

   ```


   ```

9. Prepare Cloud Foundry deployment

Install the Cloud Foundry CLI and run the following:

Download CF client for your Operating System https://github.com/cloudfoundry/cli#downloads, and install it.

   ```
# if behind a proxy, exclude this domain by setting no_proxy
# export no_proxy=192.168.50.4,xip.io
$cf api --skip-ssl-validation https://api.10.244.0.34.xip.io
$cf auth admin admin
$cf create-org  DC4Cities
$cf target -o DC4Cities
$cf create-space TrentoTrial
$cf target -s TrentoTrial
   ```
10. Prepare a multi-tier application by creating three CF applications

Create a directory for the frontend tier, and populate it with a simple application for example PHP file as the following:

   ```
$mkdir ~/git/frontend/
$cd ~/git/frontend/
$vim index.php
   ```

Go to the app directory and issue the following command:

   ```
$cf push frontend -n frontend -k 100M -m 128M

   ```

Repeat the same process for the elaboration, and backend tiers:

   ```
$mkdir ~/git/elaboration/
$cd ~/git/elaboration/
$vim index.php
$cf push elaboration -n elaboration -k 100M -m 128M

$mkdir ~/git/backend/
$cd ~/git/backend/
$vim index.php
$cf push backend -n backend -k 100M -m 128M
   ```

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
