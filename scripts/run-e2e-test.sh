#!/bin/bash

set -e

. $(dirname $0)/env.sh

_onSignal() {
  EXIT_CODE=$?
  # Kill all child processes (running servers.)
  kill 0
  # Need to explicitly kill ourselves to let the caller know we died from a
  # signal.  Ref: http://www.cons.org/cracauer/sigint.html
  sig=$1
  trap - $sig  # disable this signal so we don't capture it again.
  if [[ "$sig" == "ERR" ]];
    exit $EXIT_CODE
  else
    kill $sig $$
  fi
}

for s in ERR HUP INT QUIT PIPE TERM ; do
  trap "_onSignal $s" $s
done


# run e2e / protractor tests
#
# Must be sourced from run-test.sh

install_deps() {(
  mkdir e2e_bin
  cd e2e_bin
  # selenium
  curl -O http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.0.jar
  # chromedriver
  curl -O http://chromedriver.storage.googleapis.com/2.10/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip
)}


# Start selenium
start_servers() {(
  # Run examples.
  ( 
    cd example
    pub install
    pub build
    rsync -rl --exclude packages web/ build/web/
    rm -rf build/web/packages
    ln -s $PWD/packages build/web/packages
  )
  (cd example/build/web && python -m SimpleHTTPServer 8080) >/dev/null 2>&1 &

  # Allow chromedriver to be found on the system path.
  export PATH=$PATH:$PWD/e2e_bin

  # Start selenium.  Kill all output - selenium is extremely noisy.
  java -jar ./e2e_bin/selenium-server-standalone-2.42.0.jar >/dev/null 2>&1 &

  sleep 4 # wait for selenium startup
)}


# Main
install_deps
start_servers
(cd test_e2e && pub install)
./node_modules/.bin/protractor_dart test_e2e/examplesConf.js
