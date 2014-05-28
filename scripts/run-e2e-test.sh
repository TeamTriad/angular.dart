#!/bin/false

(
# Run everything in a subshell so all child processes are in one process group
# that we can cleanup together.
trap "kill 0" SIGINT SIGTERM EXIT

# run e2e / protractor tests
#
# Must be sourced from run-test.sh

install_deps() {(
  mkdir e2e_bin
  cd e2e_bin
  # selenium
  curl -O https://selenium.googlecode.com/files/selenium-server-standalone-2.39.0.zip
  # chromedriver
  curl -O http://chromedriver.storage.googleapis.com/2.10/chromedriver_linux64.zip
)}


# Start selenium
start_servers() {(
  # Run examples.
  (
    cd example
    pub build
    pub serve --port=8080 &
  )

  # Allow chromedriver to be found on the system path.
  export PATH=$PATH:$PWD/e2e_bin

  # Start selenium.
  java -jar ./e2e_bin/selenium-server-standalone-2.39.0.jar &
)}


# Main
install_deps
start_servers
(cd test_e2e && pub install)
./node_modules/.bin/protractor_dart test_e2e/examplesConf.js

)
