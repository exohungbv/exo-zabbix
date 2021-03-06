################################################################################
#
#   This module manages the Zabbix installation with the following limitations :
#     - Zabbix Server 2.2 : Ubuntu 12.04
#     - Zabbix Agent  2.2 : Ubuntu 14.04 + 12.04 + 10.04
#     - Zabbix Agent  1.8 : Ubuntu 11.04
#
#   Take note that this module only manage Zabbix for MySQL (not PostgreSQL yet)
#
# == Parameters
#
# [+agent+]
#   (OPTIONAL) (default: true)
#
#   allow zabbix agent on this node (true) or not (false)
#
# [+agent_port+]
#   (OPTIONAL) (default: 10050)
#
#   the port used by the zabbix agent to listen for active check
#
# [+agent_unsafe_userparameters+]
#   (OPTIONAL) (default: true)
#
#   Allow all characters to be passed in arguments to user-defined parameters.
#   If false, the following char are not passed to the UserParameter : <pre> \ ' � ` * ? [ ] { } ~ $ ! & ; ( ) < > | # @ </pre>
#   Supported since Zabbix 1.8.2.
#
# [+server+]
#   (OPTIONAL) (default: false)
#
#   allow zabbix server on this node (true) or not (false)
#
# [+server_hostname+]
#   (MANDATORY) (default: )
#
#   the full hostname of the zabbix server
#
# [+server_port+]
#   (OPTIONAL) (default: 10051)
#
#   the port used by the zabbix server to listen for agent connexions
#
# [+db_host+]
#   (OPTIONAL) (default: localhost)
#
#   the host which contains the MySQL server to use.
#
# [+db_name+]
#   (OPTIONAL) (default: zabbix)
#
#   the name of the database to use.
#
# [+db_user+]
#   (OPTIONAL) (default: zabbix)
#
#   the user to connect to the zabbix database.
#
# [+db_password+]
#   (OPTIONAL) (default: wJPnl2ZEDCit)
#
#   the password of the user to connect to the zabbix database.
#
# [+slack_webhook_url]
#   (OPTIONAL) (no default)
#
#   The url to the slack webhook to send alert to like https://hooks.slack.com/services/QW3R7Y/D34DC0D3/BCADFGabcDEF123
#
# [+frontend+]
#   (OPTIONAL) (default: false)
#
#   allow zabbix frontend on this node (true) or not (false)
#
# == Modules Dependencies
#
# [+repo+]
#   the +repo+ puppet module is needed to :
#
#   - refresh the repository before installing package (in zabbix::install)
#
# [+stdlib+]
#   the +stdlib+ puppet module is needed to :
#
#   - miscellaneous utilities functions
#
# [+mysql5+]
#   the +mysql5+ puppet module is needed to :
#
#   - create and manage the zabbix server database
#
# == Examples
#
# ===  Agent only usage
#
#   class { 'zabbix':
#       agent           => true,
#       server_hostname => 'zabbix.exemple.com',
#       server_port     => '10051',
#   }
#
# ===  Server only usage
#
#   class { 'zabbix':
#       agent           => false,
#       server          => true,
#       server_hostname => 'zabbix.exemple.com',
#       server_port     => '10051',
#   }
#
# ===  Agent and Server usage
#
#   class { 'zabbix':
#       agent           => true,
#       server          => true,
#       server_hostname => 'zabbix.exemple.com',
#       server_port     => '10051',
#   }
#
################################################################################
class zabbix (
  # Agent settings
  $agent                          = true,
  $agent_port                     = '10050',
  $agent_unsafe_userparameters    = true,
  # Server settings
  $server                         = false,
  $server_hostname                = undef,
  $server_port                    = '10051',
  $server_start_pollers           = '5',
  $server_start_trappers          = '5',
  $server_start_discoverers       = '1',
  $server_start_http_pollers      = '1',
  $server_cache_size              = '8M',
  $server_history_cache_size      = '8M',
  $server_trend_cache_size        = '4M',
  $server_history_text_cache_size = '16M',
  $server_cache_value_size        = '8M',
  $slack_webhook_url              = '',
  # Proxy settings
  $proxy                          = false,
  $proxy_hostname                 = undef,
  $proxy_port                     = '10051',
  $proxy_start_pollers            = '5',
  $proxy_start_trappers           = '5',
  $proxy_start_http_pollers       = '1',
  $proxy_cache_size               = '8M',
  $proxy_history_cache_size       = '8M',
  $proxy_history_text_cache_size  = '16M',
  $proxy_db_name                  = 'zabbix_proxy',
  # Database settings
  $db_host                        = 'localhost',
  $db_name                        = 'zabbix',
  $db_user                        = 'zabbix',
  $db_password                    = 'zabbix',
  $mysql_socket                   = '/var/run/mysqld/mysqld.sock',
  # Frontend settings
  $frontend                       = false,
  $frontend_hostname              = undef,
  $frontend_ssl                   = false,
  $frontend_apache_document_root  = '/var/www',
  $frontend_redirect2ssl          = false,) {

  # Check version compatibility
  case $::operatingsystem {
    /(Ubuntu)/ : {
      case $::lsbdistrelease {
        /(10.04)/ : {
          # allowed zabbix_version => 2.0
          if $zabbix::server == true {
            fail ("Zabbix Server is not supported on ${::operatingsystem} ${::lsbdistrelease}")
          }
          if $zabbix::proxy == true {
            fail ("Zabbix Proxy is not supported on ${::operatingsystem} ${::lsbdistrelease}")
          }
          if $zabbix::frontend == true {
            fail ("Zabbix Frontend is not supported on ${::operatingsystem} ${::lsbdistrelease}")
          }
        }
        /(10.10|11.04|11.10)/ : {
          # allowed zabbix_version => 1.8
          if $zabbix::server == true {
            fail ("Zabbix Server is not supported on ${::operatingsystem} ${::lsbdistrelease}")
          }
          if $zabbix::proxy == true {
            fail ("Zabbix Proxy is not supported on ${::operatingsystem} ${::lsbdistrelease}")
          }
          if $zabbix::frontend == true {
            fail ("Zabbix Frontend is not supported on ${::operatingsystem} ${::lsbdistrelease}")
          }
        }
        /(12.04|14.04)/       : {
          # allowed zabbix_version => 2.2
        }
        default         : {
          fail("The ${module_name} module is not supported on ${::operatingsystem} ${::lsbdistrelease}")
        }
      }
    }
    default    : {
      fail("The ${module_name} module is not supported on ${::operatingsystem}")
    }
  }

  include repo
  include stdlib
  include zabbix::params, zabbix::install, zabbix::config, zabbix::service
}
