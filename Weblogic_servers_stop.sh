echo "############################"
echo "# All Servers are STOPPING #"
echo "############################"

#!/bin/bash

dal=$(find /scratch -name 'setDomainEnv.sh' | tail -n 1 )
val=$(cat $dal | grep "WL_HOME=" | cut -d'=' -f2 )
cal=$(cat $dal | grep "DOMAIN_HOME=" | cut -d'=' -f2 | head -n 1)
WL_HOME=$(echo "$val" | tr -d '"')
DOMAIN_HOME=$(echo "$cal" | tr -d '"')

admin_url="http://den01tqd.us.oracle.com:7001"

export WL_HOME=$WL_HOME
export DOMAIN_HOME=$DOMAIN_HOME

cd $DOMAIN_HOME/servers

for file in *; do
    if [[ -d "$file" ]]; then
    	
    	if [[ "$file" != "AdminServer" ]]; then

    			nohup $DOMAIN_HOME/bin/stopManagedWebLogic.sh $file $admin_url > $DOMAIN_HOME/servers/$file/logs/$file.out

    	fi	

    fi
done	


nohup $DOMAIN_HOME/bin/stopWebLogic.sh > $DOMAIN_HOME/servers/AdminServer/logs/AdminServer.out

nohup $DOMAIN_HOME/bin/stopNodeManager.sh > $DOMAIN_HOME/nodemanager/logs/nodemanager.out


