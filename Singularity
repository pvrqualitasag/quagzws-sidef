BootStrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu/

%post
  sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
  apt update

  # install softwaree properties commons for add-apt-repository
  apt install -y software-properties-common
  apt update

  # Install libraries and other pre-requisites
  apt install -y build-essential xserver-xorg-dev freeglut3 freeglut3-dev libopenmpi-dev openmpi-bin openmpi-common openssh-client openssh-server libssh-dev libgit2-dev libssl-dev libxml2-dev libfreetype6-dev libmagick++-dev ftp screen curl man vim less locales time rsync gawk sudo tzdata git ssmtp mailutils cargo dos2unix doxygen wget
  apt update

  # Install R, Python, pandas and gnuplot
  apt install -y r-base r-base-core r-recommended python python-pip python-numpy python-pandas python-dev python3-pip pandoc gnuplot 
  apt clean

  # Install required R packages
  R --slave -e 'install.packages(c("tidyverse", "devtools", "BiocInstaller", "doParallel", "e1071", "foreach", "gridExtra", "MASS", "plyr", "stringdist", "rmarkdown", "knitr", "tinytex", "openxlsx", "LaF"), repos="https://cloud.r-project.org/", dependencies=TRUE);tinytex::install_tinytex(dir = "/opt/tinytex")'

  # Install jula from git
  curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" > julia.tar.gz 
  mkdir -p /opt/julia 
  tar -C /opt/julia -zxf julia.tar.gz 
  rm -f julia.tar.gz

  # Install jdk12 from oracle
  curl -L -b "oraclelicense=a" -O https://download.oracle.com/otn-pub/java/jdk/12.0.1+12/69cfe15208a647278a19ef0990eea691/jdk-12.0.1_linux-x64_bin.tar.gz 
  mkdir -p /opt/oracle-jdk
  tar -C /opt/oracle-jdk -zxf jdk-12.0.1_linux-x64_bin.tar.gz
  rm -rf jdk-12.0.1_linux-x64_bin.tar.gz

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
  export JULIAVER=julia-1.1.0
  export JULIAROOT=/opt/julia
  export ORACLEJDKROOT=/opt/oracle-jdk
  export ORACLEJDKVER=jdk-12.0.1
  export PATH=/opt/tinytex/bin/x86_64-linux:${JULIAROOT}/${JULIAVER}/bin:${ORACLEJDKROOT}/${ORACLEJDKVER}/bin:${PATH}:/qualstorzws01/data_projekte/linuxBin
  export LD_LIBRARY_PATH=${JULIAROOT}/${JULIAVER}/lib:${ORACLEJDKROOT}/${ORACLEJDKVER}/lib:${LD_LIBRARY_PATH}
  export TZ=$(cat /etc/timezone)

