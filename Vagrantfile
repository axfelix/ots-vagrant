VAGRANTFILE_API_VERSION = "2"

$cpus   = ENV.fetch("XMLPS_VAGRANT_CPUS", "2")
$memory = ENV.fetch("XMLPS_VAGRANT_MEMORY", "3072")
$hostname = ENV.fetch("XMLPS_VAGRANT_HOSTNAME", "xmlps")
$forward = ENV.fetch("XMLPS_VAGRANT_FORWARD", "TRUE")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.name = "XMLPS Test VM"
  end

  config.vm.hostname = $hostname

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/trusty64"


  unless  $forward.eql? "FALSE"  
    config.vm.network :forwarded_port, guest: 8008, host: 80 # Apache
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", $memory]
    vb.customize ["modifyvm", :id, "--cpus", $cpus]
  end

  shared_dir = "/vagrant"

  config.vm.provision :shell, path: "./xmlps.sh", :args => shared_dir, :privileged => false

end