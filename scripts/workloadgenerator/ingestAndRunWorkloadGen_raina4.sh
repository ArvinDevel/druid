#!/bin/sh

COMMAND="cd /proj/DCSQ/raina4/druid/scripts/ingestion/;"
COMMAND=$COMMAND" screen -d -m python ingestion.py getafix.conf;"
echo $COMMAND
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no node-1 "$COMMAND"

sleep 3

./runMultiWorkloadGen_raina4.sh $@

sleep 1m

COMMAND="cd /proj/DCSQ/raina4/druid/scripts/workloadgenerator/;"
COMMAND=$COMMAND" screen -d -m bash checkAndLog_raina4.sh $@;"
echo $COMMAND
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no node-1 "$COMMAND"