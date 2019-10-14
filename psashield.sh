#!/bin/bash
#
# Title:      PSAutomate
# Based On:   PGBlitz (Reference Title File)
# Original Author(s):  Admin9705 - Deiteq
# PSAutomate Auther: fattylewis
# URL:        https://psautomate.io - http://github.psautomate.io
# GNU:        General Public License v3.0
################################################################################
badinput() {
  echo
  read -p '⛔️ ERROR - Bad Input! | Press [ENTER] ' typed </dev/tty
}

badinput1() {
  echo
  read -p '⛔️ ERROR - Bad Input! | Press [ENTER] ' typed </dev/tty
  question1
}

variable() {
  file="$1"
  if [ ! -e "$file" ]; then echo "$2" >$1; fi
}

question1() {
  touch /psa/var/auth.bypass

  a7=$(cat /psa/var/auth.bypass)
  if [[ "$a7" != "good" ]]; then shieldcheck; fi
  echo good >/psa/var/auth.bypass

  touch /psa/var/psashield.emails
  mkdir -p /psa/var/auth/

  domain=$(cat /psa/var/server.domain)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PSA Shield | http://psashield.psautomate.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💬  PSA Shield requires Google Web Auth Keys! Visit the link above!

[1] Set Web Client ID & Secret
[2] Authorize User(s)
[3] Protect / UnProtect PSA Apps
[4] Deploy PSA Shield
[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  phase1
}

phase1() {

  read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty

  case $typed in
  1)
    webid
    phase1
    ;;
  2)
    email
    phase1
    ;;
  3)
    appexempt
    phase1
    ;;
  4)
    # Sanity Check to Ensure At Least 1 Authorized User Exists
    touch /psa/var/psashield.emails
    efg=$(cat "/psa/var/psashield.emails")
    if [[ "$efg" == "" ]]; then
      echo
      echo "SANITY CHECK: No Authorized Users have been Added! Exiting!"
      read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
      question1
    fi

    # Sanity Check to Ensure that Web ID ran domaincheck
    file="/psa/var/auth.idset"
    if [ ! -e "$file" ]; then
      echo
      echo "SANITY CHECK: You Must @ Least Run the Web ID Interface Once!"
      read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
      question1
    fi

    # Sanity Check to Ensure Ports are closed
    touch /psa/var/server.ports
    ports=$(cat "/psa/var/server.ports")
    if [ "$ports" != "127.0.0.1:" ]; then
      echo
      echo "SANITY CHECK: Ports are open, psashield cannot be enabled until they are closed due to security risks!"
      read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
      question1
    fi

    touch /psa/var/psashield.compiled
    rm -r /psa/var/psashield.compiled
    while read p; do
      echo -n "$p," >>/psa/var/psashield.compiled
    done </psa/var/psashield.emails

    ansible-playbook /psa/psashield/psashield.yml

    psastatus=$(docker ps | grep "\<thomseddon\>" | awk '{ print $2}')
    if [[ "$psastatus" != "" ]]; then touch /psa/var/oauth.exists
    else rm -rf /psa/var/oauth.exists; fi

    bash /psa/psashield/rebuild.sh
    question1
    ;;
  z)
    exit
    ;;
  Z)
    exit
    ;;
  *)
    question1
    ;;
  esac
}

appexempt() {
  bash /psa/apps/_appsgen.sh
  ls -l /psa/var/auth | awk '{ print $9 }' >/psa/var/psashield.ex15

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PSA Shield ~ App Protection | http://psashield.psautomate.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Disable psashield for a single app
2. Enable psashield for a single app
3. Reset & Enable psashield for all apps
Z. Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  phase3
}

phase3() {
  read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty

  case $typed in
  1)
    phase31
    appexempt
    ;;
  2)
    phase21
    appexempt
    ;;
  3)
    emptycheck=$(cat /psa/var/psashield.ex15)
    if [[ "$emptycheck" == "" ]]; then
      echo
      read -p 'No Apps have psashield Disabled! Exiting | Press [ENTER]'
      appexempt
    fi
    rm -rf /psa/var/auth/*
    echo ""
    echo "NOTE: Does not take effect until PG Shield is redeployed!"
    read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
    email
    appexempt
    ;;
  z)
    question1
    ;;
  Z)
    question1
    ;;
  *)
    appexempt
    ;;
  esac

}

phase31() {
  touch /psa/var/app.list
  while read p; do
    sed -i -e "/$p/d" /psa/var/app.list
  done </psa/var/psashield.ex15

  ### Blank Out Temp List
  rm -rf /psa/var/program.temp && touch /psa/var/program.temp

  ### List Out Apps In Readable Order (One's Not Installed)
  num=0
  while read p; do
    echo -n $p >>/psa/var/program.temp
    echo -n " " >>/psa/var/program.temp
    num=$((num + 1))
    if [ "$num" == 7 ]; then
      num=0
      echo " " >>/psa/var/program.temp
    fi
  done </psa/var/app.list

  notrun=$(cat /psa/var/program.temp)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PSA Shield ~ Disable Shield for an app | http://psashield.psautomate.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Apps currently protected by psashield:

$notrun

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Z] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -p '🌍 Type APP to disable psashield | Press [ENTER]: ' typed </dev/tty

  if [[ "$typed" == "exit" || "$typed" == "Exit" || "$typed" == "EXIT" || "$typed" == "z" || "$typed" == "Z" ]]; then appexempt; fi

  grep -w "$typed" /psa/var/program.temp >/psa/var/check55.sh
  usercheck=$(cat /psa/var/check55.sh)

  if [[ "$usercheck" == "" ]]; then
    echo
    read -p 'App does not exist! | Press [ENTER] ' note </dev/tty
    appexempt
  fi

  touch /psa/var/auth/$typed
  echo
  echo "NOTE: No effect until psashield or the app is redeployed!"
  read -p '🌍 Acknowledge! | Press [ENTER] ' note </dev/tty
  appexempt
}

phase21() {

  emptycheck=$(cat /psa/var/psashield.ex15)
  if [[ "$emptycheck" == "" ]]; then
    echo
    read -p 'No apps are exempt! Exiting | Press [ENTER]'
    appexempt
  fi
  ### Blank Out Temp List
  rm -rf /psa/var/program.temp && touch /psa/var/program.temp

  ### List Out Apps In Readable Order (One's Not Installed)
  num=0
  while read p; do
    echo -n $p >>/psa/var/program.temp
    echo -n " " >>/psa/var/program.temp
    num=$((num + 1))
    if [ "$num" == 7 ]; then
      num=0
      echo " " >>/psa/var/program.temp
    fi
  done </psa/var/psashield.ex15

  notrun=$(cat /psa/var/program.temp)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PSA Shield ~ Enable Shield for an app | http://psashield.psautomate.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Apps NOT currently protected by psashield:

$notrun

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Z] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -p '🌍 Type app to enable psashield | Press [ENTER]: ' typed </dev/tty

  if [[ "$typed" == "exit" || "$typed" == "Exit" || "$typed" == "EXIT" || "$typed" == "z" || "$typed" == "Z" ]]; then appexempt; fi

  grep -w "$typed" /psa/var/psashield.ex15 >/psa/var/check55.sh
  usercheck=$(cat /psa/var/check55.sh)

  if [[ "$usercheck" == "" ]]; then
    echo
    read -p 'App does not exist! | Press [ENTER] ' note </dev/tty
    appexempt
  fi

  rm -rf /psa/var/auth/$typed
  echo
  echo "NOTE: No effect until PSA Shield or the app is redeployed!"
  read -p '🌍 Acknoweldge! | Press [ENTER] ' note </dev/tty
  appexempt
}

webid() {
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔑 Google Web Keys - Client ID       📓 Reference: psashield.psautomate.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTE: Visit reference for Google Web Auth Keys

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Z] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  read -p '↘️  Web Client ID     | Press [Enter]: ' public </dev/tty
  if [ "$public" = "exit" ]; then question1; fi
  echo "$public" >/psa/var/shield.clientid

  read -p '↘️  Web Client Secret | Press [Enter]: ' secret </dev/tty
  if [ "$secret" = "exit" ]; then question1; fi
  echo "$secret" >/psa/var/shield.clientsecret

  echo ""
  read -p '🔑 Client ID & Secret Set |  Press [ENTER] ' public </dev/tty
  touch /psa/var/auth.idset
  question1
}

email() {
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PG Shield ~ Trusted Users | http://psashield.psautomate.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. E-Mail: Add User
2. E-Mail: Remove User
3. E-Mail: View Authorization List
4. E-Mail: Remove All Users (Stops PSA Shield)
Z. Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  phase2
}

phase2() {

  read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty

  case $typed in
  1)
    echo
    read -p 'User Email to Add | Press [ENTER]: ' typed </dev/tty

    emailcheck=$(echo $typed | grep "@")
    if [[ "$emailcheck" == "" ]]; then
      read -p 'Invalid E-Mail! | Press [ENTER] ' note </dev/tty
      email
    fi

    usercheck=$(cat /psa/var/psashield.emails | grep $typed)
    if [[ "$usercheck" != "" ]]; then
      read -p 'User Already Exists! | Press [ENTER] ' note </dev/tty
      email
    fi
    read -p 'User Added | Press [ENTER] ' note </dev/tty
    echo "$typed" >>/psa/var/psashield.emails
    email
    ;;
  2)
    echo
    read -p 'User Email to Remove | Press [ENTER]: ' typed </dev/tty
    testremove=$(cat /psa/var/psashield.emails | grep $typed)
    if [[ "$testremove" == "" ]]; then
      read -p 'User does not exist | Press [ENTER] ' typed </dev/tty
      email
    fi
    sed -i -e "/$typed/d" /psa/var/psashield.emails
    echo ""
    echo "NOTE: Does not take effect until PSA Shield is redeployed!"
    read -p 'Removed User | Press [ENTER] ' typed </dev/tty
    email
    email
    ;;
  3)
    echo
    echo "Current Authorized E-Mail Addresses"
    echo ""
    cat /psa/var/psashield.emails
    echo
    read -p 'Finished? | Press [ENTER] ' typed </dev/tty
    email
    email
    ;;
  4)
    test=$(cat /psa/var/psashield.emails | grep "@")
    if [[ "$test" == "" ]]; then email; fi
    docker stop oauth
    rm -r /psa/var/psashield.emails
    touch /psa/var/psashield.emails
    echo
    docker stop oauth
    read -p 'All Prior Users Removed! | Press [ENTER] ' typed </dev/tty
    email
    ;;
  z)
    question1
    ;;
  Z)
    question1
    ;;
  *)
    email
    ;;
  esac
}

shieldcheck() {
  domaincheck=$(cat /psa/var/server.domain)
  touch /psa/var/server.domain
  touch /tmp/portainer.check
  rm -r /tmp/portainer.check
  cname="portainer"
  if [[ -f "/psa/var/portainer.cname" ]]; then
    cname=$(cat "/psa/var/portainer.cname")
  fi

  wget -q "https://${cname}.${domaincheck}" -O /tmp/portainer.check
  domaincheck=$(cat /tmp/portainer.check)
  if [ "$domaincheck" == "" ]; then

    tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PSA Shield ~ Unable to talk to Portainer | psashield.psautomate.io
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Did you forget to enable Traefik?"
2. Valdiate if the portainer subdomain is working?"
3. Validate Portainer is deployed?"
4. oauth.${domain} cname in your DNS? (CloudFlare Users)"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
    exit
  fi
}

question1
