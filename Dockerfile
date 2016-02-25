FROM debian:jessie
MAINTAINER zealic <zealic@gmail.com>

ENV DEBIAN_CODENAME=jessie
RUN ln -sf /bin/bash /bin/sh
RUN echo "deb http://mirrors.ustc.edu.cn/debian $DEBIAN_CODENAME main" > /etc/apt/sources.list \
  && echo "deb-src http://mirrors.ustc.edu.cn/debian $DEBIAN_CODENAME main" >> /etc/apt/sources.list \
  && echo "deb http://mirrors.ustc.edu.cn/debian-security $DEBIAN_CODENAME/updates main" >> /etc/apt/sources.list \
  && echo "deb-src http://mirrors.ustc.edu.cn/debian-security $DEBIAN_CODENAME/updates main" >> /etc/apt/sources.list \
  && echo "deb http://mirrors.ustc.edu.cn/debian $DEBIAN_CODENAME-updates main" >> /etc/apt/sources.list \
  && echo "deb-src http://mirrors.ustc.edu.cn/debian $DEBIAN_CODENAME-updates main" >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y kvm qemu qemu-kvm curl unzip python gcc g++ make gnupg2 \
  && curl -sSL https://rvm.io/mpapis.asc | gpg2 --import - \
  && curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby \
  && source /usr/local/rvm/scripts/rvm \
  && rvm use ruby \
  && gem install --no-document rdoc rake thor json \
  && apt-get remove -y gcc g++ make gnupg2 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# For AWS AMI Builder
# Use `aws ec2 import-snapshot` to import snapshot
# Use `ec2iv` to import snapshot (China cn-north-1 region)
RUN curl -SL -o /tmp/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip \
  && mkdir -p /opt && unzip -d /opt /tmp/ec2-api-tools.zip \
  && echo 'EC2_HOME=/opt/ec2-api-tools' >> /etc/environment \
  && echo "export PATH=`dirname /opt/ec2-api-tools-*/bin`:\$PATH" > /etc/profile.d/ec2-api-tools.sh \
  && echo 'export JAVA_HOME=/usr/lib/jvm/default-jvm' > /etc/profile.d/openjdk.sh \
  && curl -SL -o /tmp/aws.zip https://s3.amazonaws.com/aws-cli/awscli-bundle.zip \
  && unzip -d /tmp /tmp/aws.zip \
  && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && chmod +x /etc/profile.d/*.sh \
  && rm -rf /tmp/* /var/tmp/*

# Packer
ENV PACKER_VERSION=0.9.0
RUN curl -SL -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
  && mkdir -p /opt/packer && unzip /tmp/packer.zip -d /opt/packer \
  && ln -sf /opt/packer/packer /usr/local/bin/packer
