BootStrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu/

%environment
  export JULIAVER=julia-1.1.0
  export JULIADL=julia.tar.gz
  export JULIAPATH=/opt/julia
  export PATH=/opt/tinytex/bin/x86_64-linux:${JULIAPATH}/${JULIAVER}/bin:${PATH}
  export LD_LIBRARY_PATH=${JULIAPATH}/${JULIAVER}/lib:${LD_LIBRARY_PATH}

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
  apt-get install -y build-essential r-base r-base-core r-recommended libopenmpi-dev openmpi-bin openmpi-common openmpi-doc openssh-client openssh-server libssh-dev libcurl4-gnutls-dev libgit2-dev libssl-dev python python-pip python-dev ftp screen curl man vim less locales time pandoc rsync
  apt-get clean

  # Install required R packages
  R --slave -e 'install.packages(c("devtools","doParallel", "e1071", "foreach","gridExtra","ggplot2","MASS","plyr","stringdist","stringr","dplyr","rmarkdown","knitr","tinytex"), repos="https://cloud.r-project.org/");tinytex::install_tinytex(dir = "/opt/tinytex")'

  # Install jula from git
  curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" > julia.tar.gz 
  mkdir -p /opt/julia 
  tar -C /opt/julia -zxf julia.tar.gz 
  rm -f julia.tar.gz

  # locales
  locale-gen en_US.UTF-8

