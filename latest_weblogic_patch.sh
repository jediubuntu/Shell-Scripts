#!/bin/bash

start=$(date +%s.%N)

dal=$(find /scratch/u01 -name 'setDomainEnv.sh' | tail -n 1 )
val=$(cat $dal | grep "WL_HOME=" | cut -d'=' -f2 )
cal=$(cat $dal | grep "DOMAIN_HOME=" | cut -d'=' -f2 | head -n 1)
WL_HOME=$(echo "$val" | tr -d '"')
DOMAIN_HOME=$(echo "$cal" | tr -d '"')

export WL_HOME=$WL_HOME
export DOMAIN_HOME=$DOMAIN_HOME

mkdir $WL_HOME/temp_patch

cd $WL_HOME
cd ..
MW_HOME=$(pwd)
export MW_HOME=$MW_HOME

cd $WL_HOME/temp_patch

PATCH_FILE="p26519424_1036_Generic.zip"

echo "################################################################################"
echo "Empty cache_dir"
echo "################################################################################"
rm -f ${MW_HOME}/utils/bsu/cache_dir/*

echo "################################################################################"
echo "Download patch file"
echo "################################################################################"
wget http://slc14urx.us.oracle.com/software/vendors/OEM_patches/${PATCH_FILE}
unzip ${PATCH_FILE}

PATCH=$(ls *.jar | cut -d'.' --complement -f2-)
CATALOG=$(ls patch-catalog*.xml)

echo "################################################################################"
echo "Patch"
echo "################################################################################"
echo "PATCH=$PATCH"
echo "CATALOG=$CATALOG"

cp $PATCH.jar ${MW_HOME}/utils/bsu/cache_dir
cp $CATALOG ${MW_HOME}/utils/bsu/cache_dir
mv ${MW_HOME}/utils/bsu/cache_dir/patch-catalog*.xml ${MW_HOME}/utils/bsu/cache_dir/patch-catalog.xml

echo "################################################################################"
echo "List cache_dir"
echo "################################################################################"
ls -la ${MW_HOME}/utils/bsu/cache_dir/${PATCH}.jar
ls -la ${MW_HOME}/utils/bsu/cache_dir/patch-catalog.xml

cd ${MW_HOME}/utils/bsu

sed -i 's/Xms128m/Xms1024m/g' bsu.sh
sed -i 's/Xms256m/Xms1024m/g' bsu.sh
sed -i 's/Xms512m/Xms1024m/g' bsu.sh
sed -i 's/Xmx256m/Xmx2048m/g' bsu.sh
sed -i 's/Xmx512m/Xmx2048m/g' bsu.sh
sed -i 's/Xmx1024m/Xmx2048m/g' bsu.sh

echo "################################################################################"
echo "Checking for conflict and  trying to apply  patch=$PATCH"
echo "################################################################################"

./bsu.sh -prod_dir=$MW_HOME/wlserver_10.3  -patch_download_dir=$MW_HOME/utils/bsu/cache_dir -patchlist=${PATCH} -verbose -install > $WL_HOME/temp_patch/1.txt

PATCH_TO_REMOVE=$(grep 'mutually exclusive and cannot coexist with patch(es):' $WL_HOME/temp_patch/1.txt | cut -d':' -f2 | cut -d' ' -f2)

if [ -n "$PATCH_TO_REMOVE" ]; then

  echo "################################################################################"
  echo "Removing conflicting patch(es)=$PATCH_TO_REMOVE"
  echo "################################################################################"

  ${MW_HOME}/utils/bsu/bsu.sh -remove -prod_dir=${MW_HOME}/wlserver_10.3 -patchlist=${PATCH_TO_REMOVE}

  echo "################################################################################"
  echo "Applying patch $PATCH  NOW !!! "
  echo "################################################################################"

  ${MW_HOME}/utils/bsu/bsu.sh -prod_dir=${MW_HOME}/wlserver_10.3 -patchlist=${PATCH} -verbose -install
fi

echo "############"
echo "Status"
echo "############"

./bsu.sh -view -status=applied -prod_dir=${MW_HOME}/wlserver_10.3

rm -rf $WL_HOME/temp_patch


end=$(date +%s.%N)
runtime=$(python -c "print(${end} - ${start})")

echo "Runtime was $runtime"