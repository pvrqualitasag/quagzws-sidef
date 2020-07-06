BootStrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu/

%files
  /home/quagadmin/simg/quagzws-sidef/inst/extdata/input/cran_pkg.txt /root
  /home/quagadmin/simg/quagzws-sidef/inst/extdata/input/carch_pkg.txt /root
  
%post
  sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
  apt-get update
  
  # locales
  echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
  apt-get install -y locales

  locale-gen en_US.UTF-8
  locale-gen de_CH.UTF-8

  # time
  apt-get install -y time 
  apt-get install -y tzdata 

  # set your timezone
  ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime  
  dpkg-reconfigure --frontend noninteractive tzdata

  # install softwaree properties commons for add-apt-repository
  apt-get install -y software-properties-common apt-utils
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
  apt-get update

  # Install libraries and other pre-requisites
  apt-get install -y build-essential xserver-xorg-dev freeglut3 freeglut3-dev libopenmpi-dev openmpi-bin openmpi-common openssh-client openssh-server libssh-dev libgit2-dev libssl-dev libxml2-dev libfreetype6-dev libmagick++-dev ftp screen curl man vim less locales time rsync gawk sudo tzdata git ssmtp mailutils cargo dos2unix doxygen wget sshpass htop nano
  apt-get update

  # Install R, Python, pandas and gnuplot
  apt-get install -y r-base r-base-core r-recommended python python-pip python-numpy python-pandas python-dev python3-pip pandoc gnuplot 
  apt-get update
  
  # Install R-packages
  R -e "cran_con<-file('/root/cran_pkg.txt');vec_cran<-readLines(cran_con);close(cran_con);install.packages(pkgs = vec_cran, repos = 'https://stat.ethz.ch/CRAN/', dependencies = TRUE)"
  R -e "carch_con<-file('/root/carch_pkg.txt');vec_carch<-readLines(carch_con);close(carch_con);for (p in vec_carch) remotes::install_url(url = p, upgrade = 'never')"
  rm -rf /root/cran_pkg.txt /root/carch_pkg.txt

  # Install jula from git
  curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz" > julia.tar.gz 
  mkdir -p /opt/julia 
  tar -C /opt/julia -zxf julia.tar.gz 
  rm -f julia.tar.gz

  # install OpenJDK 8 (LTS) from https://adoptopenjdk.net
  curl -sSL "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jdk_x64_linux_hotspot_8u222b10.tar.gz" > openjdk8.tar.gz
  mkdir -p /opt/openjdk
  tar -C /opt/openjdk -xf openjdk8.tar.gz
  rm -f openjdk8.tar.gz

  # numpy and pandas for py3
  /usr/bin/pip3 install pandas
  /usr/bin/pip3 install numpy

  # dconf and gnuplot problem
  mkdir -p /run/user/501
  chmod -R 777 /run/user
  
  # locales
  #locale-gen en_US.UTF-8
  #locale-gen de_CH.UTF-8

  # timezone
  #echo 'Europe/Berlin' > /etc/timezone

  # hostname
  echo '1-htz.quagzws.com' > /etc/hostname

%environment
  export PATH=${PATH}:/opt/openjdk/jdk8u222-b10/bin:/qualstorzws01/data_projekte/linuxBin
  export TZ=$(cat /etc/timezone)

