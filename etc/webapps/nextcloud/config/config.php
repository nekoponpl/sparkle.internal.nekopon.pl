<?php
$CONFIG = array (
  'datadirectory' => '/var/lib/nextcloud/data',
  'logfile' => '/var/log/nextcloud/nextcloud.log',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/usr/share/webapps/nextcloud/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/lib/nextcloud/apps',
      'url' => '/wapps',
      'writable' => true,
    ),
  ),
  'instanceid' => '',
  'passwordsalt' => '',
  'secret' => '',
  'trusted_domains' => 
  array (
    0 => 'cloud.internal.nekopon.pl',
  ),
  'dbtype' => 'mysql',
  'version' => '23.0.0.10',
  'overwrite.cli.url' => 'https://cloud.internal.nekopon.pl',
  'dbname' => 'nextcloud',
  'dbhost' => 'localhost:/var/run/mysqld/mysqld.sock',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => '',
  'default_phone_region' => 'PL',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'memcache.local' => '\\OC\\Memcache\\Redis',
  'redis' => 
  array (
    'host' => '/run/redis/redis.sock',
    'port' => 0,
  ),
  'installed' => true,
);
