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
  apt-get install -y build-essential r-base r-base-core r-recommended libopenmpi-dev openmpi-bin openmpi-common openmpi-doc openssh-client openssh-server libssh-dev libcurl4-gnutls-dev libgit2-dev libssl-dev python python-pip python-dev
  apt-get clean

  # Install required R packages
  R --slave -e 'install.packages(c("devtools","doParallel", "e1071", "foreach","gridExtra","ggplot2","MASS","plyr","stringdist","stringr"), repos="https://cloud.r-project.org/")'

