## packer-boxes
Provided vagrant boxes for develop, testing and deploy.


## Usage
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com)
3. Get box : `vagrant box add zealic/debian-8-devenv`
4. Install plugin : `vagrant plugin install vagrant-vbguest`
5. Boot vagrant environment : `vagrant init && vagrant up`

For more information, visit [Vagrant Documentation](https://docs.vagrantup.com/v2/)


## Build
To build vagrant box, you need:

1. Get an [Atlas](http://atlas.hashicorp.com) account
2. Install [Packer](http://www.packer.io)
3. Use below command:  
```
# Build vagrant
rake build:vagrant
# Build ova with manifest
rake build:ova manifest=debian-8-devenv
# Build ovf with runtime (for Cloud environment)
rake build:ovf runtime=cloud
```

### Availables tasks
* build
* generate
* push

### Availables formats
* ova (VirtualBox provider only)
* ovf (VirtualBox provider only)
* qcow2 (qemu provider only)
* vagrant

### Availables runtimes
* local (For local virtual machine)
* cloud (For cloud image, like AWS AMI or OpenStack)
* vagrant (For vagrant box)


## Boxes
### CentOS 7

#### :star: [centos-7-devenv](https://atlas.hashicorp.com/zealic/centos-7-devenv)
**Packages:**
* [Docker](https://www.docker.com)
* [Go](https://golang.org)
* [Python](https://www.python.org)
  - pip
  - virtualenv
* [Node.js](https://nodejs.org)
* [Ruby](https://www.ruby-lang.org)
  - Rake
  - Bundler


### Debian 8 (Jessie)

#### :star: [debian-8-devenv](https://atlas.hashicorp.com/zealic/debian-8-devenv)
**Packages:**
* [Docker](https://www.docker.com)
* [Go](https://golang.org)
* [Python](https://www.python.org)
  - pip
  - virtualenv
* [Node.js](https://nodejs.org)
* [Ruby](https://www.ruby-lang.org)
  - Rake
  - Bundler


License and Author
------------------

- Author : Zealic (<zealic@gmail.com>)
- Copyright : 2015, Zealic

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
