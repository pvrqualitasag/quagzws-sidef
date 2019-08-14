BootStrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu/

%post
  sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
  apt-get update

  # install softwaree properties commons for add-apt-repository
  apt-get install -y software-properties-common
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9
  add-apt-repository ppa:linuxuprising/java
  apt-get update

  # Install libraries and other pre-requisites
  apt-get install -y build-essential xserver-xorg-dev freeglut3 freeglut3-dev libopenmpi-dev openmpi-bin openmpi-common openssh-client openssh-server libssh-dev libgit2-dev libssl-dev libxml2-dev libfreetype6-dev libmagick++-dev ftp screen curl man vim less locales time rsync gawk sudo tzdata git ssmtp mailutils cargo dos2unix doxygen wget sshpass
  apt update

  # Install R, Python, pandas and gnuplot
  apt-get install -y r-base r-base-core r-recommended python python-pip python-numpy python-pandas python-dev python3-pip pandoc gnuplot 
  apt clean

  # Install jula from git
  curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz" > julia.tar.gz 
  mkdir -p /opt/julia 
  tar -C /opt/julia -zxf julia.tar.gz 
  rm -f julia.tar.gz

  # Install jdk12 from oracle, according to https://www.linuxuprising.com/2019/03/how-to-install-oracle-java-12-jdk-12-in.html
  echo oracle-java12-installer shared/accepted-oracle-license-v1-2 select true | /usr/bin/debconf-set-selections
  echo oracle-java12-installer shared/accepted-oracle-licence-v1-2 boolean true | /usr/bin/debconf-set-selections
  apt-get install -y oracle-java12-installer

  # numpy and pandas for py3
  /usr/bin/pip3 install pandas
  /usr/bin/pip3 install numpy

  # locales
  locale-gen en_US.UTF-8
  locale-gen de_CH.UTF-8

  # timezone
  echo 'Europe/Berlin' > /etc/timezone

  # hostname
  echo '1-htz.quagzws.com' > /etc/hostname

%environment
  export ORACLEJDKROOT=/opt/oracle-jdk
  export ORACLEJDKVER=jdk-12.0.1
  export PATH=/opt/tinytex/bin/x86_64-linux:${ORACLEJDKROOT}/${ORACLEJDKVER}/bin:${PATH}:/qualstorzws01/data_projekte/linuxBin
  export LD_LIBRARY_PATH=${ORACLEJDKROOT}/${ORACLEJDKVER}/lib:${LD_LIBRARY_PATH}
  export TZ=$(cat /etc/timezone)

