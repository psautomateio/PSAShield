#!/bin/bash
#
# Title:      PSAutomate
# Based On:   PGBlitz (Reference Title File)
# Original Author(s):  Admin9705 - Deiteq
# PSAutomate Auther: fattylewis
# URL:        https://psautomate.io - http://github.psautomate.io
# GNU:        General Public License v3.0
################################################################################
docker ps -a --format "{{.Names}}" >/psa/var/container.running

chown 1000:1000 -R /psa/apps
chmod 0755 -R /psa/apps

sed -i -e "/traefik/d" /psa/var/container.running
sed -i -e "/oauth/d" /psa/var/container.running
sed -i -e "/watchtower/d" /psa/var/container.running
sed -i -e "/wp-*/d" /psa/var/container.running
sed -i -e "/plex/d" /psa/var/container.running
sed -i -e "/jellyfin/d" /psa/var/container.running
sed -i -e "/emby/d" /psa/var/container.running
sed -i -e "/x2go*/d" /psa/var/container.running
sed -i -e "/authclient/d" /psa/var/container.running
sed -i -e "/dockergc/d" /psa/var/container.running

count=$(wc -l </psa/var/container.running)
((count++))
((count--))

tee <<-EOF

	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	⚠️  PSA Shield - Rebuilding Containers!
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
sleep 1.5
for ((i = 1; i < $count + 1; i++)); do
	app=$(sed "${i}q;d" /psa/var/container.running)

	tee <<-EOF

		━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		↘️  PSA Shield - Rebuilding [$app]
		━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	EOF
	echo "$app" >/tmp/program_var
	sleep .5

	if [ -e "/psa/apps/programs/$app/start.sh" ]; then /psa/apps/programs/$app/start.sh; fi
done

echo ""
tee <<-EOF
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	✅️  PSA Shield - All Containers Rebuilt!
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
read -p 'Continue? | Press [ENTER] ' name </dev/tty
