BootStrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu/

%post
  sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
  apt-get update

  # install software properties commons for add-apt-repository
  apt-get install -y software-properties-common apt-utils
  apt-get update

  # Install system software for TheSNPpit
  apt-get install -y gcc perl wget
  apt-get install -y libdbd-pg-perl libecpg6 libecpg-dev libdbi-perl libinline-perl libmodern-perl-perl libcloog-ppl1 libcloog-ppl-dev libfile-slurp-perl libpq5 libjudy-dev
  apt-get update -y
  echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
  apt-get install -y postgresql postgresql-contrib
  apt-get update -y
  apt clean

  # locales
  locale-gen en_US.UTF-8
  locale-gen de_CH.UTF-8

  # timezone
  echo 'Europe/Berlin' > /etc/timezone

  # hostname
  echo '1-htz.quagzws.com' > /etc/hostname

%environment
  #export PATH=${PATH}:/opt/openjdk/jdk8u222-b10/bin:/qualstorzws01/data_projekte/linuxBin
  export PATH=${PATH}:/qualstorzws01/data_projekte/linuxBin
  export TZ=$(cat /etc/timezone)

