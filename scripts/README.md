##RSA SCRIPT
The rsa script allows for passwordless ssh into each node. To run the rsa script, just issue the command: /rsa.sh <path-to-config-file>

##START SCRIPT
The start script sets up every node and then begins running each process.

To run the start script, just issue the command: /start_druid.sh <path-to-config-file>. When running the script for the first time, there may be errors showing up that say “screen: command not found” and “mysql: command not found”. If this happens, run the stop script (./stop_druid.sh -h <path-to-config-file>) and then run the start script again.

When prompted for a mysql password, the user can just press enter to have a blank password.

The configurations can be set in the file, common.conf.

##README FOR INGESTION SCRIPT
This script will navigate to the kafka directory and feed in data to the kafka producer. The user can specify if they want randomly generated data to be ingested or their own custom data. If they choose their own custom data, then they must include the path to the data file in the configuration file.

run the ingestion script with the command, python ingestion.py -n<#-of-data segments> <path-to-config-file>. The script will open a new kafka producer and feed in data.

The ingestion script can be changed so that other data sources can be used, however the user must also provide a corresponding json file for the realtime node. This can be included in the start script.

##README FOR WORKLOADGENERATOR
The workload generator will generate a distribution of access times, as well as a distribution of access periods, for the queries. These distributions can be specified in the configuration file.

The user can also decide which type of query to run on the data, such as TopN or Timeseries. This can also be specified in the configuraiton file.

To run the workload generator, issue the command: python Run.py <path-to-config-file>. 

The configurations can be set in the file, query.conf.

##README FOR LOGREADER
This script helps you parse 3 logs -- broker, historical and coordinator. It provides some apis to query and aggregate the collected result. You can further run functions like mean, percentile, max, etc to obtain useful metrics from the data. You can look at the examples in StatsGenerator code.

To run the log reader, issue the command python StatsGenerator.py <path-to-config-file>. You can specify the path to the log folder and where you want the result output. An example conf file is getafix.conf

##NOTE FOR RUNNING TIERED EXPERIMENTS
When running experiments in tiered mode, the user must first specify which tags belong to which historical nodes (e.g. node-1 is "hot", node-2 is "warm", etc.). This can be done in the runtime.properties file of each historical node. In order to set the tag, add the line "druid.server.tier=<label>".
