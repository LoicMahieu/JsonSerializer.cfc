#!/usr/bin/env sh

set -e

BASEDIR=$(dirname "$0")
PORT=${PORT:-80}
DOCKER_NAME=cf-JsonSerialize.cfc
WORK_DIR=$(cd "$BASEDIR/.."; pwd)

trap_with_arg() {
  func="$1" ; shift
  for sig ; do
    trap "$func $sig" "$sig"
  done
}

stopDocker(){
  echo "killing... (Trapped: $1)"
  echo Stop docker
  docker stop $DOCKER_NAME || true
  kill 0
}

rmDocker() {
  echo Try to stop docker $DOCKER_NAME
  docker stop $DOCKER_NAME || true
  echo Try to delete docker $DOCKER_NAME
  docker rm $DOCKER_NAME || true
  echo Retry...
  exit 1
}

# Stop docker on signal exit
trap_with_arg stopDocker 0 9 SIGHUP

echo "Server start: http://localhost:$PORT"

docker run --rm -i --name $DOCKER_NAME \
  -p $PORT:80 \
  -v $WORK_DIR:/var/www \
  finalcut/coldfusion10 &

wait
