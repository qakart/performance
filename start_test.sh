#!/bin/bash

source ./env.sh


for arg in "$@"
do
    LOAD_COUNT=($arg)
done

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

        printf "$(date),${TEST_PLAN[i]}_${LOAD_COUNT[j]}users_${JMETER_LOAD_TIME_MIN}min,${LOAD_COUNT[j]},$JMETER_HOST,$JMETER_LOAD_TIME," >>$JMETER_RESULT/script.txt
        echo "====${TEST_PLAN[i]}_${LOAD_COUNT[j]}users_${JMETER_LOAD_TIME_MIN}min start running ==="

        JVM_ARGS="-Xms1024m -Xmx2048m" sh $JMETER_PATH -n -t $JMETER_SRC/${TEST_PLAN[i]}.jmx -l $JMETER_RESULT/$aggregateFile -e -o $JMETER_RESULT/VQS -JreportPath=$JMETER_RESULT/$logFile -JthreadsCount=${LOAD_COUNT[j]} -Jhost=$JMETER_HOST -Jport=$JMETER_PORT -JholdLoad=$JMETER_LOAD_TIME -JhttpProtocol=$HTTP_PROTOCOL \
            -Jdev_var=$JMETER_TEST_DATA/DEV_VAR.csv \
            -Jprd_var=$JMETER_TEST_DATA/PRD_VAR.csv \
            -Jstg_var=$JMETER_TEST_DATA/STG_VAR.csv \
            -Jliveshow_list=$JMETER_TEST_DATA/liveshow_list.csv \
            -Jlogin_dev=$JMETER_TEST_DATA/login_dev.csv \
            -Jlogin_prd=$JMETER_TEST_DATA/login_prd.csv \
            -Jlogin_stg=$JMETER_TEST_DATA/login_stg.csv \
            -Jlogin_vipjr=$JMETER_TEST_DATA/login_vipjr.csv \
            -Jcreate_prd=$JMETER_TEST_DATA/account_prd.csv \
            -Jcreate_stg=$JMETER_TEST_DATA/account_stg.csv \
            -Jcreate_dev=$JMETER_TEST_DATA/account_dev.csv \
            -Jjoin_room=$JMETER_TEST_DATA/join_room.csv \
            -Jroom_stg=$JMETER_TEST_DATA/create_room.csv \
            -Jsend_groupmsg=$JMETER_TEST_DATA/send_groupmsg.csv

        java -jar $JMETER_CMD_RUNNER_PATH --tool Reporter --generate-csv $JMETER_RESULT/$aggregateFile --input-jtl $JMETER_RESULT/$logFile --plugin-type AggregateReport

        echo "==== ${TEST_PLAN[i]}_${LOAD_COUNT[j]}users_${JMETER_LOAD_TIME_MIN}min finished ==="
        echo "$(date),${TEST_PLAN[i]}" >> $JMETER_RESULT/script.txt
    done
done
END_TIME=`date +%s`

node $SCRIPT/resultAnalyse.js $testPlans $loadCounts $JMETER_RESULT $JMETER_LOAD_TIME_MIN

# node --print_code_verbose $SCRIPT/perf.js $JMETER_RESULT $MYSQL_HOST $MYSQL_USERNAME $MYSQL_PASSWORD $MYSQL_DATABASE $TIMESTAMP $END_TIME
