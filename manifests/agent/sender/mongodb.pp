class zabbix::agent::sender::mongodb ($active=true, $sender_data_file_path = '/tmp/zabbix_mongodb_status.data') inherits zabbix::params {

  file { "${zabbix::params::config_other_scripts_dir}/send_mongodb.sh":
    ensure  => $active ? {
      true    => present,
      default => absent
    },
    owner   => root,
    group   => zabbix,
    mode    => '0750',
    content => template('zabbix/v2.x/etc/zabbix/other-scripts/send_mongodb.sh.erb'),
    require => File[$zabbix::params::config_other_scripts_dir]
  } ->
  cron { 'zabbix_sender_mongodb':
    ensure  => $active ? {
      true    => present,
      default => absent
    },
    command => "${zabbix::params::config_other_scripts_dir}/send_mongodb.sh > /dev/null",
    user    => zabbix,
    target  => zabbix,
    minute  => '*',
    hour    => '*'
  }
}
