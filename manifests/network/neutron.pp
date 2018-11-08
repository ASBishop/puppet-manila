# == Class: manila::network::neutron
#
# Setup and configure Neutron communication
#
# === Parameters
#
# [*insecure*]
#   Verify HTTPS connections. (boolean value)
#   Defaults to false
#
# [*auth_url*]
#   (optional) Authentication URL (string value)
#   Defaults to $::os_service_default
#
# [*token_auth_url*]
#   (Optional) The authentication URL for the neutron
#   connection when using the current users token.
#   Defaults to $::os_service_default
#
# [*auth_type*]
#   (optional) Authentication type to load (string value)
#   Defaults to $::os_service_default
#
# [*cafile*]
#   (optional) PEM encoded Certificate Authority to use when verifying HTTPs
#   connections. (string value)
#   Defaults to $::os_service_default
#
# [*certfile*]
#   (optional) PEM encoded client certificate cert file (string value)
#   Defaults to $::os_service_default
#
# [*keyfile*]
#   (optional) PEM encoded client certificate key file (string value)
#   Defaults to $::os_service_default
#
# [*user_domain_name*]
#   (optional) User's domain name (string value)
#   Defaults to 'Default'
#
# [*project_domain_name*]
#   (optional) Domain name containing project (string value)
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) Project name to scope to (string value)
#   Defaults to 'service'
#
# [*region_name*]
#   (optional) Region name for connecting to neutron. (string value)
#   Defaults to $::os_service_default
#
# [*timeout*]
#   (optional) Timeout value for http requests (integer value)
#   Defaults to $::os_service_default
#
# [*username*]
#   (optional) Username (string value)
#   Defaults to 'neutron'
#
# [*password*]
#   (optional) User's password (string value)
#   Defaults to undef
#
# [*network_plugin_ipv4_enabled*]
#   (optional) Whether to support Ipv4 network resource
#   Defaults to $::os_service_default
#
# [*network_plugin_ipv6_enabled*]
#   (optional) whether to support IPv6 network resource
#   Defaults to $::os_service_default
#
# === DEPRECATED PARAMETERS
#
# [*neutron_api_insecure*]
#   (optional) if set, ignore any SSL validation issues
#   Defaults to false
#
# [*neutron_ca_certificates_file*]
#   (optional) Location of ca certificates file to use for
#   neutron client requests.
#   Defaults to $::os_service_default
#
# [*neutron_url*]
#   (optional) URL for connecting to neutron
#   Defaults to $::os_service_default
#
# [*neutron_url_timeout*]
#   (optional) timeout value for connecting to neutron in seconds
#   Defaults to $::os_service_default
#
# [*neutron_admin_username*]
#   (optional) username for connecting to neutron in admin context
#   Defaults to 'neutron'
#
# [*neutron_admin_password*]
#   (optional) password for connecting to neutron in admin context
#   Defaults to $::os_service_default
#
# [*neutron_admin_tenant_name*]
#   (optional) Tenant name for connecting to neutron in admin context
#   Defaults to 'service'
#
# [*neutron_region_name*]
#   (optional) region name for connecting to neutron in admin context
#   Defaults to $::os_service_default
#
# [*neutron_admin_auth_url*]
#   (optional) auth url for connecting to neutron in admin context
#   Defaults to 'http://localhost:5000/v2.0'
#
# [*neutron_auth_strategy*]
#   (optional) auth strategy for connecting to
#   neutron in admin context
#   Defaults to 'keystone'
#

class manila::network::neutron (
  $insecure                     = false,
  $auth_url                     = $::os_service_default,
  $token_auth_url               = $::os_service_default,
  $auth_type                    = $::os_service_default,
  $cafile                       = $::os_service_default,
  $certfile                     = $::os_service_default,
  $keyfile                      = $::os_service_default,
  $user_domain_name             = 'Default',
  $project_domain_name          = 'Default',
  $project_name                 = 'service',
  $region_name                  = $::os_service_default,
  $timeout                      = $::os_service_default,
  $username                     = 'neutron',
  $password                     = undef,
  $network_plugin_ipv4_enabled  = $::os_service_default,
  $network_plugin_ipv6_enabled  = $::os_service_default,
  # DEPRECATED PARAMETERS
  $neutron_api_insecure            = false,
  $neutron_ca_certificates_file    = $::os_service_default,
  $neutron_admin_username          = 'neutron',
  $neutron_admin_password          = undef,
  $neutron_admin_tenant_name       = undef,
  $neutron_admin_auth_url          = undef,
  $neutron_region_name             = undef,
) {
  if $neutron_api_insecure {
   warning('The neutron_api_insecure parameter is deprecated, use api_insecure instead.')
  }
  if $neutron_admin_auth_url {
   warning('The neutron_admin_auth_url parameter is deprecated. use auth_url instead.')
  }
  if $neutron_ca_certificates_file {
   warning('The neutron_ca_certificates_file is deprecated, use api_insecure instead.')
  }
  if $neutron_admin_tenant_name {
   warning('The neutron_admin_tenant_name parameter is deprecated. use project_name instead.')
  }
  if $neutron_admin_region_name {
   warning('The neutron_admin_region_name parameter is deprecated. use region_name instead.')
  }
  if $neutron_admin_username {
   warning('The neutron_admin_username parameter is deprecated. use username instead.')
  }
  if $neutron_admin_password {
   warning('The neutron_admin_password parameter is deprecated. use password instead.')
   $password_real = $neutron_admin_password
  } else {
   $password_real = $password
  }

  $api_insecure_real = pick($insecure, $neutron_api_insecure)
  $auth_url_real = pick($auth_url, $neutron_admin_auth_url)
  $ca_certificates_file_real = pick($ca_certificates_file, $neutron_ca_certificates_file)
  $project_name_real = pick($project_name, $neutron_admin_tenant_name)
  $region_name_real = pick($region_name, $neutron_admin_region_name)
  $username_real = pick($username, $neutron_admin_username)
  $neutron_plugin_name = 'manila.network.neutron.neutron_network_plugin.NeutronNetworkPlugin'

  manila_config {
    'DEFAULT/network_api_class':            value => $neutron_plugin_name;
    'neutron/insecure':                     value => $api_insecure_real;
    'neutron/auth_url':                     value => $auth_url_real;
    'neutron/token_auth_url':               value => $token_auth_url;
    'neutron/auth_type':                    value => $auth_type;
    'neutron/cafile':                       value => $cafile;
    'neutron/certfile':                     value => $certfile;
    'neutron/keyfile':                      value => $keyfile;
    'neutron/user_domain_name':             value => $user_domain_name;
    'neutron/project_domain_name':          value => $project_domain_name;
    'neutron/project_name':                 value => $project_name_real;
    'neutron/region_name':                  value => $region_name_real;
    'neutron/timeout':                      value => $timeout;
    'neutron/username':                     value => $username_real;
    'neutron/password':                     value => $password_real, secret => true;
    'neutron/network_plugin_ipv4_enabled':  value => $network_plugin_ipv4_enabled;
    'neutron/network_plugin_ipv6_enabled':  value => $network_plugin_ipv6_enabled;
    }

}
