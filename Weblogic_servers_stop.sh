echo "############################"
echo "# All Servers are STOPPING #"
echo "############################"

#!/bin/bash

dal=$(find /scratch/u01 -name 'setDomainEnv.sh' | tail -n 1 )
val=$(cat $dal | grep "WL_HOME=" | cut -d'=' -f2 )
cal=$(cat $dal | grep "DOMAIN_HOME=" | cut -d'=' -f2 | head -n 1)
WL_HOME=$(echo "$val" | tr -d '"')
DOMAIN_HOME=$(echo "$cal" | tr -d '"')

admin_url="http://den02odi.us.oracle.com:7001"

export WL_HOME=$WL_HOME
export DOMAIN_HOME=$DOMAIN_HOME

cd $DOMAIN_HOME/servers

for file in *; do
    if [[ -d "$file" ]]; then

        if [[ "$file" != "AdminServer" ]]; then

                        sh $DOMAIN_HOME/bin/stopManagedWebLogic.sh $file $admin_url  >> /scratch/u01/app/oracle/try/$

        fi

    fi
done


sh $DOMAIN_HOME/bin/stopWebLogic.sh >> /scratch/u01/app/oracle/try/2.out

kill -9 `ps -ef | grep [N]odeManager | awk '{print $2}'`


