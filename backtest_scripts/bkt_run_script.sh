#!/bin/bash

SLEEPSEC=2
BKTHOME=/home/kevinli/asm_maneki_bkt/
STYDIR=$BKTHOME/algo_trade/sample1/
LOGDIR=$STYDIR/log/
export JAVA_OPTS="-Xmx2G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=2G -Xss2M  -Duser.timezone=GMT";

###################################################
# capi
###################################################
restart_capi() {
    cd $BKTHOME/capi_protocol_server_dbnstb_bkt/bin/
    bash stop_capi.sh
    sleep $SLEEPSEC
    bash start_capi.sh
    sleep $SLEEPSEC
}
###################################################
stop_capi() {
    cd $BKTHOME/capi_protocol_server_dbnstb_bkt/bin/
    bash stop_capi.sh
    sleep $SLEEPSEC
}
###################################################

export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH

mv $LOGDIR $STYDIR/log_$(date +'%Y%m%d_%H%M%S')
mkdir $LOGDIR
rm -f  $BKTHOME/capi_protocol_server_dbnstb_bkt/data/log/*.log
rm -rf $BKTHOME/capi_protocol_server_dbnstb_bkt/data/log/feedLog/*
rm -rf $BKTHOME/capi_protocol_server_dbnstb_bkt/data/log/log/*

ps aux | grep scalable | grep stratEngine | awk '{print $2}' | xargs kill -9
$BKTHOME/stratEngine/bin/scalable-strategy-engine $BKTHOME/stratEngine/bkt.properties > /dev/null 2>&1 &
sleep $SLEEPSEC

cd $BKTHOME/algo_trade/sample1/bin/
#./simple_capi_protocol_client.py reset_tbl_for_backtest $(date +'%Y-%m-%d') > /dev/null 2>&1
./simple_capi_protocol_client.py reset_tbl_for_backtest $(date +'%Y-%m-%d')
sleep $SLEEPSEC

for DATESTR in $(cat $BKTHOME/date_list.txt)
do
    restart_capi

    cd $BKTHOME/algo_trade/sample1/bin/
    ps aux | grep simple_capi_protocol_client.py | awk '{print $2}' | xargs kill -9
    ps aux | grep nc | grep 60934 | awk '{print $2}' | xargs kill -9
    ./simple_capi_protocol_client.py market_open  $DATESTR > $BKTHOME/algo_trade/sample1/log/cronjob_market_open_"$DATESTR".log 2>&1 &
    # nc -l -p 60934
    $BKTHOME/terminator.py
    ps aux | grep simple_capi_protocol_client.py | grep market_open | awk '{print $2}' | xargs kill -9
    sleep $SLEEPSEC

    stop_capi

    cd $BKTHOME/algo_trade/sample1/bin/
    ps aux | grep simple_capi_protocol_client.py | awk '{print $2}' | xargs kill -9
    ps aux | grep nc | grep 60934 | awk '{print $2}' | xargs kill -9
    ./simple_capi_protocol_client.py market_close $DATESTR > $BKTHOME/algo_trade/sample1/log/cronjob_market_close_"$DATESTR".log 2>&1 &
    # nc -l -p 60934
    $BKTHOME/terminator.py
    ps aux | grep simple_capi_protocol_client.py | grep market_close | awk '{print $2}' | xargs kill -9
    sleep $SLEEPSEC

done
