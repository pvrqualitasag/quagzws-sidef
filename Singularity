BootStrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu/

%post
  sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
  apt-get update

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
  
  # Install system software for TheSNPpit
  apt-get install -y libdbd-pg-perl libecpg6 libecpg-dev libdbi-perl libinline-perl libmodern-perl-perl libcloog-ppl1 libcloog-ppl-dev libfile-slurp-perl libpq5 libjudy-dev
  apt-get update -y
  echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
  apt-get install -y postgresql postgresql-contrib
  apt-get update
  apt clean
  
  # Install additional perl-modules for TheSNPPit
  curl -sSL "https://raw.githubusercontent.com/pvrqualitasag/quagzws-sidef/master/etc/needed_perl_modules_tsp" > needed_perl_modules_tsp
  curl -sSL "https://raw.githubusercontent.com/pvrqualitasag/quagzws-sidef/master/bash/install_perlmd_tsp.pl" > install_perlmd_tsp.pl
  perl -w install_perlmd_tsp.pl
  rm -rf install_perlmd_tsp.pl needed_perl_modules_tsp
  

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

  # permissions for postgres
  chmod -R 755 /var/lib/postgresql/10/main
  chmod -R 777 /var/run/postgresql
  
  # dconf and gnuplot problem
  mkdir -p /run/user/501
  chmod -R 777 /run/user
  
  # locales
  locale-gen en_US.UTF-8
  locale-gen de_CH.UTF-8

  # timezone
  echo 'Europe/Berlin' > /etc/timezone

  # hostname
  echo '1-htz.quagzws.com' > /etc/hostname

%environment
  export PATH=${PATH}:/opt/openjdk/jdk8u222-b10/bin:/qualstorzws01/data_projekte/linuxBin
  export TZ=$(cat /etc/timezone)

