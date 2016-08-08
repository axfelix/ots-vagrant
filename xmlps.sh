#!/bin/bash

# This will get you a working environment on a stock Ubuntu 14.04
# Pull it down separately, run from your home directory

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
sudo apt-get update
sudo -E apt-get install -q -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:andrei-pozolotin/maven3
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo add-apt-repository -y ppa:libreoffice/ppa
sudo apt-get update
sudo -E apt-get -q -y install bibutils libreoffice ure uno-libs3 python3-uno libreoffice-script-provider-python unoconv python-lxml exiftool pandoc pandoc-citeproc libghc-citeproc-hs-data ruby openjdk-7-jdk libxml-twig-perl libxml-writer-string-perl libxml-writer-perl php5.6-xsl php5.6-curl php5.6-cli php5.6-mysql php5.6-zip sendmail build-essential mysql-server apache2 php5.6-common php5.6 wget curl zip git maven3
sudo apt-get upgrade -y php5.6-common
wget -O crfpp.deb https://www.dropbox.com/s/svgq8xyz7bbouov/crfpp_0.58-raring-ppa0_amd64.deb?dl=0
wget -O libcrfpp.deb https://www.dropbox.com/s/zuycitdtyxuisfz/libcrfpp-dev_0.58-raring-ppa0_amd64.deb?dl=0
sudo dpkg -i *.deb
git clone https://github.com/mit-nlp/MITIE
cd MITIE
make MITIE-models
cd tools/ner_stream
make
sudo mkdir /opt/mitie
sudo cp ner_stream /opt/mitie/.
sudo mv ../../MITIE-models /opt/mitie/.
cd ../../..
wget https://github.com/kermitt2/grobid/archive/grobid-parent-0.4.0.zip
unzip grobid-parent-0.4.0.zip
sudo mv grobid-grobid-parent-0.4.0 /opt/grobid
cd /opt/grobid
mvn -Dmaven.test.skip=true clean install
cd grobid-service
mvn -Dmaven.test.skip=true jetty:run-war&
cd /var/www/
sudo git clone https://github.com/pkp/xmlps.git
sudo rm html/index.html
sudo rmdir html
sudo mv xmlps html
cd html
sudo chown -R www-data:$USER /var/www
sudo chown -R www-data:$USER /var/cache
sudo chown -R www-data:$USER /var/local
sudo chmod -R 775 /var/www/html
rm var/cache/zfcache-ea/*
php composer.phar self-update
php composer.phar update
php composer.phar install
sudo service mysql start
mysqladmin -uroot create xmlps
cp config/autoload/local.php.dist config/autoload/local.php
sed "s/'user' => '',/'user' => 'root',/g" -i config/autoload/local.php
vendor/doctrine/doctrine-module/bin/doctrine-module orm:schema-tool:update --force
rm /var/www/html/vendor/pkp/ParsCit/crfpp/crf_learn
rm /var/www/html/vendor/pkp/ParsCit/crfpp/crf_test
ln -s /usr/bin/crf_learn /var/www/html/vendor/pkp/ParsCit/crfpp/.
ln -s /usr/bin/crf_test /var/www/html/vendor/pkp/ParsCit/crfpp/.
sudo wget -O /etc/apache2/sites-available/xmlps.conf https://raw.githubusercontent.com/pkp/xmlps/master/docs/xmlps.conf
sudo rm /etc/apache2/sites-enabled/*
sudo ln -s /etc/apache2/sites-available/xmlps.conf /etc/apache2/sites-enabled/xmlps.conf
sudo ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
sudo service apache2 restart
sudo chsh -s /bin/bash www-data
sudo su -c "bash /var/www/html/start_queues.sh" www-data
grobidcroncommand="cd /opt/grobid/grobid-service && mvn -Dmaven.test.skip=true jetty:run-war&"
grobidcron="@reboot $grobidcroncommand"
cat <(fgrep -i -v "$grobidcroncommand" <(crontab -l)) <(echo "$grobidcron") | crontab -
apachecroncommand="sudo service apache2 restart"
apachecron="@reboot $apachecroncommand"
cat <(fgrep -i -v "$apachecroncommand" <(crontab -l)) <(echo "$apachecron") | crontab -
sudo su -c 'cat <(fgrep -i -v "cd /var/www/html && bash /var/www/html/start_queues.sh" <(crontab -l)) <(echo "@reboot cd /var/www/html && bash /var/www/html/start_queues.sh") | crontab -' www-data