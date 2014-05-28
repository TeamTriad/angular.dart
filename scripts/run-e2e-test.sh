#!/bin/false
#
# run e2e / protractor tests
#
# Must be sourced from run-test.sh

install_deps() {(
  mkdir e2e_bin
  cd e2e_bin
  # selenium
  curl -O https://selenium.googlecode.com/files/selenium-server-2.32.0.zip
  # chromedriver
  curl -O http://chromedriver.storage.googleapis.com/2.10/chromedriver_linux64.zip
)}


# Start selenium
start_servers() {(
  # Kill all background jobs (technically, all processes in the current process
  # group) on exit.
  trap "kill 0" SIGINT
  trap "kill 0" SIGTERM
  trap "kill 0" EXIT

  # Run examples.
  (cd example && pub serve) &

  # Allow chromedriver to be found on the system path.
  export PATH=$PATH:$PWD/e2e_bin

  # Start selenium.
  java -jar ./e2e_bin/selenium-server-standalone-2.39.0.jar &

  # Wait for pub serve to get somewhere.
  # TODO(chirayuk): do this in a smarter way with some timeout.
  sleep 10
)}

start_servers
./node_modules/.bin/protractor_dart test/e2e/examplesConf.js
