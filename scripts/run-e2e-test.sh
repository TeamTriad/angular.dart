#!/bin/false

set -vx

(
# Run everything in a subshell so all child processes are in one process group
# that we can cleanup together.
trap "kill 0" SIGINT SIGTERM
trap "EXIT_CODE=$?; kill 0; exit $EXIT_CODE" ERR

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
    rm -rf build/web/packages
    rsync -rl web/ build/web/
  )
  (cd example/build/web && python -m SimpleHTTPServer 8080) &

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
EXIT_CODE=$?
echo ckck: FINISHED RUNNING protractor tests.  Now explicitly exiting.
exit $EXIT_CODE
echo ckck: should NOT have reached here.

)
