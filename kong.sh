#!/bin/bash
#将工作目录切换到脚本所在目录
basepath=$(cd `dirname $0`; pwd)
cd ${basepath}

#获取服务名称
servicename=${basepath##*/}

printHelp() {
    cat <<EOF

Usage: kong.sh COMMAND DATASOURCE

Commands:
  start  start or update the service
  stop   stop the service

Data sources:
  postgres   use the postgres container as the data source
  cassandra  use the cassandra container as the data source
  external   use external database service instead of docker container

EOF
}

checkDatabaseType() {
    if [ "$1" != 'postgres' -a "$1" != 'cassandra' -a "$1" != 'external' ]
    then
        printHelp
        exit 1
    fi
}

checkDatabaseType $2
if [ "$1" == 'start' ]
then
    while true
    do
        case $2 in
            postgres)
            `docker-compose -f docker-compose.yml -f docker-compose.postgres.yml up -d ${@:3}`
            ;;
            cassandra)
            `docker-compose -f docker-compose.yml -f docker-compose.cassandra.yml up -d ${@:3}`
            ;;
            external)
            `docker-compose -f docker-compose.yml up -d ${@:3}`
            ;;
        esac

        `curl -s http://127.0.0.1:8000 > /dev/null`
        kongStatus=$?
        `curl -s http://127.0.0.1:1337 > /dev/null`
        kongaStatus=$?
        if [ "${kongStatus}" == "0" -a "${kongaStatus}" == "0" ]
        then
            break
        fi

        sleep 3
    done
elif [ "$1" == 'stop' ]
then
    case $2 in
        postgres)
        `docker-compose -f docker-compose.yml -f docker-compose.postgres.yml down ${@:3}`
        ;;
        cassandra)
        `docker-compose -f docker-compose.yml -f docker-compose.cassandra.yml down ${@:3}`
        ;;
        external)
        `docker-compose -f docker-compose.yml down ${@:3}`
        ;;
    esac
else
    printHelp
fi
