#!/bin/sh

OPENSHIFT_RUNTIME_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime
OPENSHIFT_REPO_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime/repo

# INSTALL APACHE
cd $OPENSHIFT_RUNTIME_DIR
mkdir srv
mkdir srv/pcre
mkdir srv/httpd
mkdir srv/php
mkdir tmp
cd tmp/
wget http://apache.mirror.gtcomm.net//httpd/httpd-2.4.25.tar.gz
tar -zxf httpd-2.4.25.tar.gz
wget http://artfiles.org/apache.org/apr/apr-1.5.2.tar.gz
tar -zxf apr-1.5.2.tar.gz
mv apr-1.5.2 httpd-2.4.25/srclib/apr
wget http://artfiles.org/apache.org/apr/apr-util-1.5.4.tar.gz
tar -zxf apr-util-1.5.4.tar.gz
mv apr-util-1.5.4 httpd-2.4.25/srclib/apr-util
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz
tar -zxf pcre-8.40.tar.gz
cd pcre-8.40
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/pcre
make && make install
cd ../httpd-2.4.25
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/httpd \
--with-included-apr \
--with-pcre=$OPENSHIFT_RUNTIME_DIR/srv/pcre \
--enable-so \
--enable-load-all-modules \
--enable-auth-digest \
--enable-auth-form \
--enable-rewrite \
--enable-setenvif \
--enable-mime \
--enable-deflate \
--enable-headers
make && make install
cd ..
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tar.gz

# COPY TEMPLATES
cp $OPENSHIFT_REPO_DIR/misc/templates/bash_profile.tpl $OPENSHIFT_HOMEDIR/app-root/data/.bash_profile
python $OPENSHIFT_REPO_DIR/misc/httpconf.py

# START APACHE
$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apachectl start
