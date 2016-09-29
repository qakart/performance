#!/bin/bash

source ./env.sh

testLen=${#TEST_PLAN[@]}
loadLen=${#LOAD_COUNT[@]}

testPlans=${TEST_PLAN[0]}
loadCounts=${LOAD_COUNT[0]}


for ((i=1;i<testLen;i++))
    do testPlans=$testPlans","${TEST_PLAN[i]}
done

for ((i=1;i<loadLen;i++))
    do loadCounts=$loadCounts","${LOAD_COUNT[i]}
done



mkdir $JMETER_RESULT

for ((i=0;i<testLen;i++))
do
    for ((j=0;j<loadLen;j++))
    do
        logFile=`echo ${TEST_PLAN[i]}\_${LOAD_COUNT[j]}users\_${JMETER_LOAD_TIME_MIN}min.jtl`
        aggregateFile=`echo ${TEST_PLAN[i]}\_${LOAD_COUNT[j]}users\_${JMETER_LOAD_TIME_MIN}min_aggregate.jtl`
        #errorlogFile=`echo ${TEST_PLAN[i]}\_${LOAD_COUNT[j]}users\_${JMETER_LOAD_TIME_MIN}min\_error.jtl`
        serverPerf=`echo ${TEST_PLAN[i]}\_${LOAD_COUNT[j]}users\_${JMETER_LOAD_TIME_MIN}min\_server.jtl`
        serverPerfGraph=`echo ${TEST_PLAN[i]}\_${LOAD_COUNT[j]}users\_${JMETER_LOAD_TIME_MIN}min\_server_graph.png`

        serverPerfMem=`echo ${TEST_PLAN[i]}\_${LOAD_COUNT[j]}users\_${JMETER_LOAD_TIME_MIN}min\_mem.jtl`
        serverPerfMemGraph=`echo ${TEST_PLAN[i]}\_${LOAD_COUNT[j]}users\_${JMETER_LOAD_TIME_MIN}min\_mem_graph.png`

        printf "$(date +%s),${TEST_PLAN[i]}_${LOAD_COUNT[j]}users_${JMETER_LOAD_TIME_MIN}min,${LOAD_COUNT[j]},$JMETER_HOST,$JMETER_LOAD_TIME," >>$JMETER_RESULT/script.txt
        echo "====${TEST_PLAN[i]}_${LOAD_COUNT[j]}users_${JMETER_LOAD_TIME_MIN}min start running ==="

        sh $JMETER_PATH -n -t $JMETER_SRC/${TEST_PLAN[i]}.jmx -JreportPath=$JMETER_RESULT/$logFile -JthreadsCount=${LOAD_COUNT[j]} -Jliveshow_list=$JMETER_TEST_DATA/liveshow_list.csv -Jpassword_login=$JMETER_TEST_DATA/password_login.csv -Jhost=$JMETER_HOST -Jport=$JMETER_PORT -JholdLoad=$JMETER_LOAD_TIME -JhttpProtocol=$HTTP_PROTOCOL
        java -jar $JMETER_CMD_RUNNER_PATH --tool Reporter --generate-csv $JMETER_RESULT/$aggregateFile --input-jtl $JMETER_RESULT/$logFile --plugin-type AggregateReport

        echo "==== ${TEST_PLAN[i]}_${LOAD_COUNT[j]}users_${JMETER_LOAD_TIME_MIN}min finished ==="
        echo "$(date +%s),${TEST_PLAN[i]}" >> $JMETER_RESULT/script.txt
    done
done
END_TIME=`date +%s`

node $SCRIPT/resultAnalyse.js $testPlans $loadCounts $JMETER_RESULT $JMETER_LOAD_TIME_MIN

# node $SCRIPT/vls_perf.js $JMETER_RESULT $MYSQL_HOST $MYSQL_USERNAME $MYSQL_PASSWORD $MYSQL_DATABASE $TIMESTAMP $END_TIME
