# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANT_API_VERSION = 2

Vagrant.configure(VAGRANT_API_VERSION) do |config|
  config.vm.box = "zealic/debian-8-devenv"

  config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 1024]
  end

  config.vm.provision "shell", inline: <<-SHELL
    # For AWS AMI (China)
    # Use `ec2iv`
    sudo apt-get -y install openjdk-7-jre
    curl -sSL -o /tmp/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
    sudo unzip -d /opt /tmp/ec2-api-tools.zip
    sudo echo 'EC2_HOME=/opt/ec2-api-tools' >> /etc/environment
    sudo echo "export PATH=`dirname /opt/ec2-api-tools-*/bin`:\$PATH" > /etc/profile.d/ec2-api-tools.sh
    sudo echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' > /etc/profile.d/openjdk.sh
    sudo chmod +x /etc/profile.d/*.sh
    # For AWS AMI
    # Use `aws ec2 import-snapshot` to import snapshot
    curl -sSL -o /tmp/aws.zip https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    unzip -d /tmp /tmp/aws.zip
    sudo /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  SHELL
end

# Load Vagrantfile.local to overwrite or extend default Vagrant configuration
load "Vagrantfile.local" if File.exist?("Vagrantfile.local")
