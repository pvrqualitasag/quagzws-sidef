BootStrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu/

%post
  sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
  apt-get update

  # install softwaree properties commons for add-apt-repository
  apt-get install -y software-properties-common
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9
  apt-get update

  # Install R, Python, misc. utilities
  apt-get install -y build-essential r-base r-base-core r-recommended libopenmpi-dev openmpi-bin openmpi-common openmpi-doc openssh-client openssh-server libssh-dev libcurl4-gnutls-dev libgit2-dev libssl-dev python python-pip python-dev ftp screen curl man vim less locales time pandoc rsync gawk sudo tzdata 
  apt-get clean

  # Install required R packages
  R --slave -e 'install.packages(c("devtools","doParallel", "e1071", "foreach","gridExtra","ggplot2","MASS","plyr","stringdist","stringr","dplyr","rmarkdown","knitr","tinytex"), repos="https://cloud.r-project.org/");tinytex::install_tinytex(dir = "/opt/tinytex")'

  # Install jula from git
  curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" > julia.tar.gz 
  mkdir -p /opt/julia 
  tar -C /opt/julia -zxf julia.tar.gz 
  rm -f julia.tar.gz

  # Install jdk8 from oracle
  curl -L -b "oraclelicense=a" -O https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz
  mkdir -p /opt/oracle-jdk8
  tar -C /opt/oracle-jdk8 -zxf jdk-8u201-linux-x64.tar.gz
  rm -rf jdk-8u201-linux-x64.tar.gz

  # locales
  locale-gen en_US.UTF-8
  locale-gen de_CH.UTF-8

  # timezone
  echo 'Europe/Berlin' > /etc/timezone

%environment
  export JULIAVER=julia-1.1.0
  export JULIADL=julia.tar.gz
  export JULIAPATH=/opt/julia
  export PATH=/opt/tinytex/bin/x86_64-linux:${JULIAPATH}/${JULIAVER}/bin:/opt/oracle-jdk8/jdk1.8.0_201/bin:${PATH}:/qualstorzws01/data_projekte/linuxBin
  export LD_LIBRARY_PATH=${JULIAPATH}/${JULIAVER}/lib:/opt/oracle-jdk8/jdk1.8.0_201/lib:${LD_LIBRARY_PATH}
  export TZ=$(cat /etc/timezone)

