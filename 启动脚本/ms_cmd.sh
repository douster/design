#! /bin/sh

export DOCKER_IP=192.168.1.128

DOCKER_IP=${DOCKER_IP:-0.0.0.0}

PATH_VERSION="0.0.1-SNAPSHOT"

#启动服务
function start_core(){
    if [ ! -d "/data/es/openec/logs" ]; then
  	mkdir -p /data/es/openec/logs
    fi

    if [ ! -f "/data/es/openec/logs/$1_out.log" ]; then
        touch "/data/es/openec/logs/$1_out.log"
    fi

    echo "[START_COMMAND]: java -Djava.security.egd=file:/dev/./urandom -jar /data/es/openec/$1-$PATH_VERSION.jar >/data/es/openec/logs/$1_out.log &"
    exec java -Djava.security.egd=file:/dev/./urandom -jar /data/es/openec/$1-$PATH_VERSION.jar >/data/es/openec/logs/$1_out.log &
    exit 1
}

#关闭服务
function stop_core(){
    _SERVICE_NAME=/data/es/openec/$1-$PATH_VERSION
    _NAME_SUFFIXX="\>"
    _PROC_ID=`ps -ef|grep -i ${_SERVICE_NAME}${_NAME_SUFFIXX}|grep -v "grep"|awk '{print $2}'`

    echo "[STOP_PID]:" $_PROC_ID
    if [ ! $_PROC_ID = "" ]; then
       kill -9 $_PROC_ID
    fi
}

#重启服务
function restart_core(){
    stop_core $1
    start_core $1
}

#服务列表
function ms_list(){
    ps -ef | grep java | grep "/data/es/openec/"
}

#输出用例
function echo_help_info(){
        echo "USAGE: `basename $0` [ start | stop | restart ] [ service name ]"
        echo "       `basename $0` [ list ]"
#        echo "  -s SERVICE_NAME "
        exit 1
}

function _exec(){
    function select_action(){

        if [ $1 = "START" ]; then
            start_core $2
            if [ ! $? -eq 0 ]; then
                exit 1
            fi
        fi

        if [ $1 = "STOP" ]; then
            stop_core $2
            if [ ! $? -eq 0 ]; then
                exit 1
            fi
        fi

        if [ $1 = "RESTART" ]; then
            restart_core $2
            if [ ! $? -eq 0 ]; then
                exit 1
            fi
        fi

        if [ $1 = "LIST" ]; then
            ms_list $2
            if [ ! $? -eq 0 ]; then
                exit 1
            fi
        fi

    }

select_action $1 $2

}



#判断参数的正确性
if [ $# -eq 0 ]; then
       echo_help_info
fi

if [ $1 = "start" ]; then
    ACTION="START"
fi

if [ $1 = "stop" ]; then
    ACTION="STOP"
fi

if [ $1 = "restart" ]; then
    ACTION="RESTART"
fi

if [ $1 = "list" ]; then
    ACTION="LIST"
fi

if [ $1 != "start" ] && [ $1 != "stop" ] && [ $1 != "restart" ] && [ $1 != "list" ]; then #判断输入值是否合法
    echo_help_info
fi

shift

SERVICE_NAME=$1

if [ $ACTION != "LIST" ] && [ $# -eq 0 ]; then
       echo_help_info
fi

echo "###############SCRIPT-START##############"
echo "[ACTION]:" $ACTION
if [ $ACTION != "LIST" ]; then
    echo "[SERVICE_NAME]:" $SERVICE_NAME
fi

_exec $ACTION $SERVICE_NAME
