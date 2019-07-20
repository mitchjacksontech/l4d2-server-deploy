require 'yaml';
conf = YAML.load(File.read('deploy_l4d2_server.yaml'))

unless ENV['LINODE_API_KEY']
  print("Please set the environment variable LINODE_API_KEY.  See README.md\n")
  exit 1
end

Vagrant.configure('2') do |config|

  config.vm.box = 'centos/7'
  config.vm.hostname = 'l4d2'

  config.vm.network "public_network"

#   config.vm.provider "virtualbox" do |v|
#     v.memory = 4096
#     v.cpus = 2
#   end

  # See https://github.com/displague/vagrant-linode
  config.vm.provider :linode do |provider, override|
    override.ssh.private_key_path = conf['l4d2_rsa_key']
    # override.vm.box = 'linode'
    # override.vm.box_url = "https://github.com/displague/vagrant-linode/raw/master/box/linode.box"
    override.vm.box = 'linode/ubuntu1404'

    # https://github.com/displague/vagrant-linode/issues/76
    override.nfs.functional = false

    provider.api_key = conf['LINODE_API_KEY']
    provider.distribution = 'CentOS 7'
    provider.datacenter = 'atlanta'
    provider.label = 'l4d2_server'

    # Currently Dedicated CPU instance is $0.045/hr
    provider.plan = 'Dedicated 4GB'

  end

  config.vm.provision :shell, path: "deploy_l4d2_server.sh", env: conf
end
