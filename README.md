# Left4Dead2 Dedicated Centos Server On Linode

Quicky deploy and tear down a cloud L4D2 server on Linode using Vagrant

## Setup and Configuration

You will need [Vagrant](https://vagrantup.com) installed to begin

You will need to
[create a Linode API key](https://manager.linode.com/profile/api) API key.
This will allow vagrant to provision and deprovision your VPS server automatically.
This must be done in the old linode v3 control panel.  The new linode v4
control panel creates "Personal Access Tokens" which are not supported by
vagrant-linode. [ref](https://github.com/displague/vagrant-linode/issues/95)

```bash
# Clone this repository
git clone https://github.com/mitchjacksontech/l4d2-server-deploy.git
cd l4d2-server-deploy

# Create a config file from the included sample config file.
cp deploy_l4d2_server.yaml.sample deploy_l4d2_server.yaml

# Edit the config file
vi ./deploy_l4d2_server.yaml

# Install the vagrant-linode plugin
vagrant plugin install vagrant-linode
```

## Run a server

Create the server with the command `vagrant up`.  This command may take a
few minutes to complete.  WHen the server becomes available, you will see
the server listed in your Steam Group Servers inside the game

To start a game on your server, create a lobby, and set server type to
Steam Group Server.

To access the server via ssh, use the command `vagrant ssh`

To turn the server off, use the command `vagrant halt`.  Note that, while a
server is turned off, linode still bills you for it's resources.

To destroy a server completly, and stop paying the per-hour fee (currently
4.5 cents per hour for this setup) use the command `vagrant destroy`

## Server mods

Automating deployment of server mods looks time consuming.  I'm not
going to do it
