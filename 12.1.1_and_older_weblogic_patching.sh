#!/bin/bash

dal=$(find /scratch -name 'setDomainEnv.sh' | head -n 1 )
val=$(cat $dal | grep "WL_HOME=" | cut -d'=' -f2 )
WL_HOME=$(echo "$val" | tr -d '"')

export WL_HOME=$WL_HOME
cd $WL_HOME
cd ..
MW_HOME=$(pwd)
export MW_HOME=$MW_HOME

PATCH_TO_REMOVE="D33T"
PATCH_FILE="p26519424_1036_Generic.zip"

echo "################################################################################"
echo "Empty cache_dir"
echo "################################################################################"
rm -f ${MW_HOME}/utils/bsu/cache_dir/*

echo "################################################################################"
echo "Download patch file"
echo "################################################################################"
wget http://slc06mye.us.oracle.com/software/vendors/OEM_patches/${PATCH_FILE}
unzip ${PATCH_FILE}

PATCH= `ls *.jar | cut -d'.' --complement -f2-`
CATALOG= `ls patch-catalog*.xml`

echo "################################################################################"
echo "Patch"
echo "################################################################################"
echo "PATCH=$PATCH"
echo "CATALOG=$CATALOG"

cp ${PATCH}.jar ${MW_HOME}/utils/bsu/cache_dir/.
cp ${CATALOG} ${MW_HOME}/utils/bsu/cache_dir/patch-catalog.xml

echo "################################################################################"
echo "List cache_dir"
echo "################################################################################"
ls -la ${MW_HOME}/utils/bsu/cache_dir/${PATCH}.jar
ls -la ${MW_HOME}/utils/bsu/cache_dir/patch-catalog.xml

cd ${MW_HOME}/utils/bsu
#./bsu.sh -view -status=applied -prod_dir=${MW_HOME}/wlserver_10.3

if [ -n "$PATCH_TO_REMOVE" ]; then
  ${MW_HOME}/utils/bsu/bsu.sh -remove -prod_dir=${MW_HOME}/wlserver_10.3 -patchlist=${PATCH_TO_REMOVE}
fi

${MW_HOME}/utils/bsu/bsu.sh -prod_dir=${MW_HOME}/wlserver_10.3 -patchlist=${PATCH} -verbose -install


