#!/bin/bash

ORIGDIR=`pwd`
TEMPDIR=/tmp/fontforge-app-bundle
rm -rf /tmp/fontforge-app-bundle
mkdir $TEMPDIR

bundle_res=$TEMPDIR/FontForge.app/Contents/Resources
bundle_bin="$bundle_res/opt/local/bin"
bundle_lib="$bundle_res/opt/local/lib"
bundle_etc="$bundle_res/opt/local/etc"

cp ./fontforge/MacFontForgeAppBuilt.zip $TEMPDIR/
unzip -d $TEMPDIR $TEMPDIR/MacFontForgeAppBuilt.zip
DESTDIR=$bundle_res make install

cd $bundle_bin
dylibbundler --overwrite-dir --bundle-deps --fix-file \
  ./fontforge \
  --install-path @executable_path/../lib \
  --dest-dir ../lib

mkdir -p $bundle_lib
cp -av /opt/local/lib/pango   $bundle_lib

OLDPREFIX=/opt/local
NEWPREFIX=/Applications/FontForge.app/Contents/Resources/opt/local

mkdir -p $bundle_etc
cp -av /opt/local/etc/fonts   $bundle_etc
cp -av /opt/local/etc/pango   $bundle_etc
cd $bundle_etc/pango
sed -i -e "s|$OLDPREFIX|$NEWPREFIX|g" pangorc
sed -i -e "s|$OLDPREFIX|$NEWPREFIX|g" pango.modules
cd $bundle_etc/fonts
sed -i -e "s|$OLDPREFIX|$NEWPREFIX|g" fonts.conf 
sed -i -e 's|<fontconfig>|<fontconfig><dir>/Applications/FontForge.app/Contents/Resources/opt/local/share/fontforge/pixmaps/</dir>|g' fonts.conf

cd $bundle_lib/pango/
cd `find . -type d -maxdepth 1 -mindepth 1`
cd `find . -type d -maxdepth 1 -mindepth 1`

echo "Bundling up the pango libs to point in the right directions... at `pwd`"

for if in `pwd`/*.so
do
    dylibbundler -x "$if" \
      --install-path @executable_path/../lib \
      --dest-dir "$bundle_lib"
done



cd $TEMPDIR
zip -r ~/MacFontForgeBundledApp.zip FontForge.app

echo "Completed at `date`"
ls -lh `echo ~`/MacFontForgeBundledApp.zip




