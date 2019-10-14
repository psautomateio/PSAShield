#!/bin/bash
#
# Title:      PSAutomate
# Based On:   PGBlitz (Reference Title File)
# Original Author(s):  Admin9705 
# PSAutomate Auther: fattylewis
# URL:        https://psautomate.io - http://github.psautomate.io
# GNU:        General Public License v3.0
################################################################################
touch /var/psautomate
if [[ $(docker ps | grep oauth) == "" ]]; then
  echo null >/psa/var/auth.var
else
  echo good >/psa/var/auth.var
fi
