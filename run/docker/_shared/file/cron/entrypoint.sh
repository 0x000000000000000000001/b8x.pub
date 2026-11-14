#!/bin/sh

chmod -R 0777 /tmp &>/dev/null

# Important fix, see https://stackoverflow.com/questions/34962020/cron-and-crontab-files-not-executed-in-docker/38850273#38850273#answer-38850273
touch /etc/crontab /etc/cron.*/*

# Permission rights fixes, see https://superuser.com/questions/947840/how-to-configure-a-cron-d-crontab-file-for-root#answer-948370
chown -R root:root /etc/cron.d
chmod -R 644 /etc/cron.d
chown -R root:root /etc/logrotate.d
chmod -R 644 /etc/logrotate.d

touch /var/log/cron.log
touch /var/log/cron.error.log

env >> /etc/environment

exec "$@"
