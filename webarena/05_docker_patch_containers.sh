#!/bin/bash

# stop if any error occur
set -e

source 00_vars.sh

# reddit - make server more responsive
docker exec forum sed -i \
  -e 's/^pm.max_children = .*/pm.max_children = 32/' \
  -e 's/^pm.start_servers = .*/pm.start_servers = 10/' \
  -e 's/^pm.min_spare_servers = .*/pm.min_spare_servers = 5/' \
  -e 's/^pm.max_spare_servers = .*/pm.max_spare_servers = 20/' \
  -e 's/^;pm.max_requests = .*/pm.max_requests = 500/' \
  /usr/local/etc/php-fpm.d/www.conf
docker exec forum supervisorctl restart php-fpm

# shopping + shopping admin
docker exec shopping /var/www/magento2/bin/magento setup:store-config:set --base-url="http://$PUBLIC_HOSTNAME:$SHOPPING_PORT" # no trailing /
docker exec shopping mysql -u magentouser -pMyPassword magentodb -e  "UPDATE core_config_data SET value='http://$PUBLIC_HOSTNAME:$SHOPPING_PORT/' WHERE path = 'web/secure/base_url';"
# remove the requirement to reset password
docker exec shopping_admin php /var/www/magento2/bin/magento config:set admin/security/password_is_forced 0
docker exec shopping_admin php /var/www/magento2/bin/magento config:set admin/security/password_lifetime 0
docker exec shopping /var/www/magento2/bin/magento cache:flush

docker exec shopping_admin /var/www/magento2/bin/magento setup:store-config:set --base-url="http://$PUBLIC_HOSTNAME:$SHOPPING_ADMIN_PORT"
docker exec shopping_admin mysql -u magentouser -pMyPassword magentodb -e  "UPDATE core_config_data SET value='http://$PUBLIC_HOSTNAME:$SHOPPING_ADMIN_PORT/' WHERE path = 'web/secure/base_url';"
docker exec shopping_admin /var/www/magento2/bin/magento cache:flush

# gitlab
docker exec gitlab sed -i "s|^external_url.*|external_url 'http://$PUBLIC_HOSTNAME:$GITLAB_PORT'|" /etc/gitlab/gitlab.rb
docker exec gitlab bash -c "printf '\n\npuma[\"worker_processes\"] = 4' >> /etc/gitlab/gitlab.rb"  # bugfix https://github.com/ServiceNow/BrowserGym/issues/285
docker exec gitlab gitlab-ctl reconfigure

# maps
docker exec openstreetmap-website-web-1 bin/rails db:migrate RAILS_ENV=development

# reddit
# forum - update rate limit to allow more requests
echo "Updating forum rate limit"
# in SubmissionData.php, we replace the max=3 to max=50, and 1 hour to 2 minutes, and 15 to 50, and 5 minutes to 2 minutes
sudo docker exec reddit sed -i 's/1 hour/2 minutes/g' /var/www/html/src/DataObject/SubmissionData.php
sudo docker exec reddit sed -i 's/5 minutes/2 minutes/g' /var/www/html/src/DataObject/SubmissionData.php
sudo docker exec reddit sed -i 's/max=3/max=50/g' /var/www/html/src/DataObject/SubmissionData.php
sudo docker exec reddit sed -i 's/max=15/max=50/g' /var/www/html/src/DataObject/SubmissionData.php
# in CommentData.php, we replace the 5 minutes limit to 2 minutes, and max=10 to max=50
sudo docker exec reddit sed -i 's/5 minutes/2 minutes/g' /var/www/html/src/DataObject/CommentData.php
sudo docker exec reddit sed -i 's/max=10/max=50/g' /var/www/html/src/DataObject/CommentData.php
# in UserData.php, we replace the max="3" to max="50", and 1 hour to 2 minutes
sudo docker exec reddit sed -i 's/max="3"/max="50"/g' /var/www/html/src/DataObject/UserData.php
sudo docker exec reddit sed -i 's/1 hour/2 minutes/g' /var/www/html/src/DataObject/UserData.php
# reset cache to make sure the new rate limit is applied
sudo docker exec -it reddit bash -lc 'php bin/console cache:clear --env=prod || rm -rf var/cache/prod'
sudo docker exec -it reddit bash -lc 'php -r "function_exists(\"opcache_reset\") && opcache_reset(); echo \"OPcache reset\n\";"'
