#! /bin/bash

############################## PRE PROCESSING ################################
#check and process arguments
REQUIRED_NUMBER_OF_ARGUMENTS=2
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
	echo "Usage: $0 <type_of_stop> <path_to_config_file>"
	echo "Type of stop: -h for hard, -s for soft"
	exit 1
fi

if [ "$1" == "-h" ]
then
	TYPE_OF_STOP=1
elif [ "$1" == "-s" ]
then
	TYPE_OF_STOP=0
else
	echo "Unrecongized stop type: -h for hard, -s for soft"
	exit 1
fi

CONFIG_FILE=$2

echo "Config file is $CONFIG_FILE"
echo ""

#get the configuration parameters
source $CONFIG_FILE

############################## PROCESS CONFIG FILE ################################
#construct realtime FQDN
NEW_REALTIME_NODE=''
for node in ${REALTIME_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        REALTIME_NODE_FQDN=$node
    else
        REALTIME_NODE_FQDN=$node.$EXPERIMENT.$PROJ.$ENV
    fi
 
    NEW_REALTIME_NODE=$NEW_REALTIME_NODE$USER_NAME@$REALTIME_NODE_FQDN
done

#construct broker FQDN
NEW_BROKER_NODES=''
for node in ${BROKER_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_BROKER_NODES=$NEW_BROKER_NODES$node,
    else
        NEW_BROKER_NODES=$NEW_BROKER_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV
    fi
done

#construct historical FQDNs
NEW_HISTORICAL_NODES=''
for node in ${HISTORICAL_NODES//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_HISTORICAL_NODES=$NEW_HISTORICAL_NODES$node,
    else
        NEW_HISTORICAL_NODES=$NEW_HISTORICAL_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV,
    fi
done

#construct coordinator FQDNs
NEW_COORDINATOR_NODES=''
for node in ${COORDINATOR_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_COORDINATOR_NODES=$NEW_COORDINATOR_NODES$node,
    else
        NEW_COORDINATOR_NODES=$NEW_COORDINATOR_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV
    fi
done

#construct zookeeper FQDNs
NEW_ZOOKEEPER_NODES=''
for node in ${ZOOKEEPER_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_ZOOKEEPER_NODES=$NEW_ZOOKEEPER_NODES$node,
    else
        NEW_ZOOKEEPER_NODES=$NEW_ZOOKEEPER_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV
    fi
done

#construct mysql FQDNs
NEW_MYSQL_NODES=''
for node in ${MYSQL_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_MYSQL_NODES=$NEW_MYSQL_NODES$node,
    else
        NEW_MYSQL_NODES=$NEW_MYSQL_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV
    fi
done

#construct overlord FQDNs
NEW_OVERLORD_NODES=''
for node in ${OVERLORD_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_OVERLORD_NODES=$NEW_OVERLORD_NODES$node,
    else
        NEW_OVERLORD_NODES=$NEW_OVERLORD_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV
    fi
done

#construct middle manager FQDNs
NEW_MIDDLE_MANAGER_NODES=''
for node in ${MIDDLE_MANAGER_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_MIDDLE_MANAGER_NODES=$NEW_MIDDLE_MANAGER_NODES$node,
    else
        NEW_MIDDLE_MANAGER_NODES=$NEW_MIDDLE_MANAGER_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV
    fi
done

#construct kafka FQDNs
NEW_KAFKA_NODES=''
for node in ${KAFKA_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_KAFKA_NODES=$NEW_KAFKA_NODES$node,
    else
        NEW_KAFKA_NODES=$NEW_KAFKA_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV
    fi
done

#construct broker FQDN
NEW_REDIS_NODES=''
for node in ${REDIS_NODE//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        NEW_REDIS_NODES=$NEW_REDIS_NODES$node,
    else
        NEW_REDIS_NODES=$NEW_REDIS_NODES$USER_NAME@$node.$EXPERIMENT.$PROJ.$ENV,
    fi
done

############################ SHUTDOWN ##########################################

#generate keys for passwordless ssh
#echo -ne '\n' | ssh-keygen;
#for node in ${NEW_COORDINATOR_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_HISTORICAL_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_BROKER_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_REALTIME_NODE//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_ZOOKEEPER_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_OVERLORD_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_MIDDLE_MANAGER_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_MYSQL_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done
#for node in ${NEW_KAFKA_NODES//,/ }
#do
#    ssh-copy-id -i ~/.ssh/id_rsa.pub $node;
#done

#shutdown redis
#counter=0
#echo "Shutting down redis nodes:"
#for  node in ${NEW_REDIS_NODES//,/ }
#do

#        echo "Setting up $node ..."
#        COMMAND=''

#        COMMAND=$COMMAND" cd $PATH_TO_REDIS_BIN && ./create-cluster stop"

#        if [ "$IP" == "TRUE" ]
#        then
#            COMMAND=$COMMAND" --bind_ip $node;"
#        else
#            COMMAND=$COMMAND";"
#        fi
#        echo "redis node shutdown command is $COMMAND"

    #ssh to node and run command
#        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
#            $COMMAND"
#done
#echo ""

#shutdown the kafka server
echo "Shutting down kafka server:"
counter=0
for node in ${NEW_KAFKA_NODES//;/ }
do
    echo "Shutting down $node ..."
    COMMAND=''
    if [ $TYPE_OF_STOP -eq 1 ]
    then
        COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
    fi
    COMMAND=$COMMAND" cd $PATH_TO_DRUID_BIN;"
    COMMAND=$COMMAND" cd kafka_2.10-0.8.2.1;"
    COMMAND=$COMMAND" ./bin/kafka-topics.sh --zookeeper $KAFKA_NODE-big-lan:2181 --delete --topic metrics;"
    COMMAND=$COMMAND" ./bin/kafka-server-stop.sh;"
    COMMAND=$COMMAND" ./bin/zookeeper-server-stop.sh;"
    echo "kafka server shutdown command is $COMMAND"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
        $COMMAND"
done
echo""

#shutdown the zookeeper server
echo "Shutting down zookeeper server:"
counter=0
for node in ${NEW_ZOOKEEPER_NODES//;/ }
do
    echo "Shutting down $node ..."
    COMMAND=''
    if [ $TYPE_OF_STOP -eq 1 ]
    then
        COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
    fi
    COMMAND=$COMMAND" cd $PATH_TO_ZOOKEEPER && sudo bin/zkServer.sh stop;"
    echo "zookeeper server shutdown command is $COMMAND"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
       $COMMAND"
done
echo""

#shutdown the mysql server
echo "Shutting down mysql server:"
counter=0
for node in ${NEW_MYSQL_NODES//;/ }
do
    echo "Shutting down $node ..."
    COMMAND=''
    if [ $TYPE_OF_STOP -eq 1 ]
    then
        COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
    fi
    COMMAND=$COMMAND" sudo service mysql stop"
    COMMAND=$COMMAND" sudo service mysql start"
    MYSQL="DROP DATABASE druid;"
    COMMAND=$COMMAND" mysql -u root -p -e \"$MYSQL\";"
    COMMAND=$COMMAND" sudo apt-get -y remove mysql-server;"
    echo "mysql server shutdown command is $COMMAND"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
       $COMMAND"
done
echo""

#shutdown the middle manager server
echo "Shutting down middle manager server:"
counter=0
for node in ${NEW_MIDDLE_MANAGER_NODES//;/ }
do
    echo "Shutting down $node ..."
    COMMAND=''
    if [ $TYPE_OF_STOP -eq 1 ]
    then
        COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
    fi
    COMMAND=$COMMAND" pkill -9 "screen";"
    echo "middle manager server shutdown command is $COMMAND"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
       $COMMAND"
done
echo""

#shutdown the overlord server
echo "Shutting down overlord server:"
counter=0
for node in ${NEW_OVERLORD_NODES//;/ }
do
    echo "Shutting down $node ..."
    COMMAND=''
    if [ $TYPE_OF_STOP -eq 1 ]
    then
        COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
    fi
    COMMAND=$COMMAND" pkill -9 "screen";"
    echo "overlord server shutdown command is $COMMAND"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
       $COMMAND"
done
echo""

#shutdown the broker server
echo "Shutting down broker server:"
counter=0
for node in ${NEW_BROKER_NODES//;/ }
do
    echo "Shutting down $node ..."
    COMMAND=''
    if [ $TYPE_OF_STOP -eq 1 ]
    then
        COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
    fi
    COMMAND=$COMMAND" pkill -9 "screen";"
    echo "Broker server shutdown command is $COMMAND"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
       $COMMAND"
done
echo""

#shutdown the realtime server
echo "Shutting down realtime server:"
counter=0
for node in ${NEW_REALTIME_NODE//;/ }
do
    echo "Shutting down $node ..."
    COMMAND=''
    if [ $TYPE_OF_STOP -eq 1 ]
    then
    COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
    fi
    COMMAND=$COMMAND" pkill -9 "screen";"
    echo "Realtime server shutdown command is $COMMAND"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
       $COMMAND"

done
echo""

#shutdown the coordinator server
echo "Shutting down coordinator server:"
counter=0
for  node in ${NEW_COORDINATOR_NODES//,/ }
do
        echo "Shutting down $node ..."
        COMMAND=''
        COMMAND=$COMMAND"pkill -9 "screen";"
        echo "Config server shutdown command is $COMMAND"
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
			$COMMAND"
		let counter=counter+1;
done
echo ""

#shutdown the historical server
echo "Shutting down historical servers:"
for  node in ${NEW_HISTORICAL_NODES//,/ }
do
        echo "Shutting down $node ..."
        COMMAND=''
        if [ $TYPE_OF_STOP -eq 1 ]
        then
        	COMMAND=$COMMAND"sudo rm -r -f $LOG_FOLDER;"
        fi
	COMMAND=$COMMAND"pkill -9 "screen";"
        echo "Historical server shutdown command is $COMMAND"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
        	$COMMAND"
done
echo ""