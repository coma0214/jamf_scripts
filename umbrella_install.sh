#!/bin/bash

install_modules() {
  sleep 5
  cd /tmp/airwatch/ || return
  vpn_install=$(sudo installer  -verboseR  -pkg vpn_module.pkg -target /)
  umbrella_install=$(sudo installer -verboseR -pkg umbrella_module.pkg -target /)
  hostname=$(hostname)
  sudo cp OrgInfo.json /opt/cisco/anyconnect/umbrella
  job_logging="{\"hostname\": \"$hostname\", \"vpn_status\": \"$vpn_install\", \"umbrella_status\": \"$umbrella_install\"}"
  clean_response=$(echo "$job_logging" | tr -d '\n')
  response=$(curl -s -i -H "Accept: application/json" -X POST -d "$clean_response" https://eu.webhook.logs.insight.rapid7.com/v1/noformat/bb0342e6-ed0f-46c9-8abb-2e4568622a78)
  if test "$response" != "0"; then
    echo "The logging curl command succeeded with: $response"
  fi
}

install_umbrella() {
  sleep 5
  cd /tmp/airwatch/ || return
  umbrella_install=$(sudo installer  -verboseR -pkg umbrella_module.pkg -target /)
  hostname=$(hostname)
  sudo cp OrgInfo.json /opt/cisco/anyconnect/umbrella
  job_logging="{\"hostname\": \"$hostname\", \"umbrella_status\": \"$umbrella_install\"}"
  clean_response=$(echo "$job_logging" | tr -d '\n')
  response=$(curl -s -i -H "Accept: application/json" -X POST -d "$clean_response" https://eu.webhook.logs.insight.rapid7.com/v1/noformat/bb0342e6-ed0f-46c9-8abb-2e4568622a78)
  if test "$response" != "0"; then
    echo "The logging curl command succeeded with: $response"
  fi
}

check_version() {
  version=$(defaults read /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/Contents/Info.plist CFBundleShortVersionString)
  echo "$version"
  cd /opt/cisco/AnyConnect/ || exit
  if pgrep acumbrellaagent; then
    exit
  fi

  if [[ ("$version" < "4.8.01090" || "$version" > "4.8.01090") ]]; then
    cd /opt/cisco/anyconnect/bin || exit

    if [[ -f anyconnect_uninstall.sh ]]; then
      sudo ./anyconnect_uninstall.sh
      install_modules
    else
      install_modules
    fi

  else
    install_umbrella
  fi
}

if pgrep acumbrellaagent; then
  check_version
else
  if [[ -e /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/ ]]; then
    check_version
  else
    install_modules
  fi
fi
