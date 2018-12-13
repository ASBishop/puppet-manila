# == Class: manila::compute::nova
#
# Setup and configure Nova communication
#
# === Parameters
#
# [*insecure*]
#   (optional) Verify HTTPS connections
#   Defaults to false
#
# [*auth_url*]
#   (optional) Authentication URL
#   Defaults to $::os_service_default
#
# [*token_auth_url*]
#   (Optional) The authentication URL for the nova
#   connection when using the current users token.
#   Defaults to $::os_service_default
#
# [*auth_type*]
#   (optional) Authentication type to load
#   Defaults to $::os_service_default
#
# [*cafile*]
#   (optional) PEM encoded Certificate Authority to use when verifying HTTPS
#   connections.
#   Defaults to $::os_service_default
#
# [*certfile*]
#   (optional) PEM encoded client certificate cert file
#   Defaults to $::os_service_default
#
# [*keyfile*]
#   (optional) PEM encoded client certificate key file
#   Defaults to $::os_service_default
#
# [*user_domain_name*]
#   (optional) User's domain name
#   Defaults to 'Default'
#
# [*project_domain_name*]
#   (optional) Domain name containing project
#   Defaults to 'Default'
#
# [*project_name*]
#   (optional) Project name to scope to
#   Defaults to 'service'
#
# [*region_name*]
#   (optional) Region name for connecting to nova
#   Defaults to $::os_service_default
#
# [*timeout*]
#   (optional) Timeout value for http requests
#   Defaults to $::os_service_default
#
# [*username*]
#   (optional) Username
#   Defaults to 'nova'
#
# [*password*]
#   (optional) User's password
#   Defaults to undef
#
# === DEPRECATED PARAMETERS
#
# [*nova_catalog_info*]
#   (optional) Info to match when looking for nova in the service
#   catalog. Format is : separated values of the form:
#   <service_type>:<service_name>:<endpoint_type>
#   Defaults to 'compute:nova:publicURL'
#
# [*nova_catalog_admin_info*]
#   (optional) Same as nova_catalog_info, but for admin endpoint.
#   Defaults to 'compute:nova:adminURL'
#
# [*nova_api_insecure*]
#   (optional) Allow to perform insecure SSL requests to nova.
#   Defaults to false
#
# [*nova_ca_certificates_file*]
#   (optional) Location of CA certificates file to use for nova client requests.
#   (string value)
#   Defaults to $::os_service_default
#
# [*nova_admin_username*]
#   (optional) Nova admin username.
#   Defaults to 'nova'
#
# [*nova_admin_password*]
#   (optional) Nova admin password.
#   Defaults to undef
#
# [*nova_admin_tenant_name*]
#   (optional) Nova admin tenant name.
#   Defaults to 'service'
#
# [*nova_admin_auth_url*]
#  (optional) Identity service url.
#   Defaults to 'http://localhost:5000/v2.0'
#

class manila::compute::nova (
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
  $username                     = 'nova',
  $password                     = undef,
  # DEPRECATED PARAMETERS
  $nova_catalog_info            = 'compute:nova:publicURL',
  $nova_catalog_admin_info      = 'compute:nova:adminURL',
  $nova_api_insecure            = false,
  $nova_ca_certificates_file    = $::os_service_default,
  $nova_admin_username          = undef,
  $nova_admin_password          = undef,
  $nova_admin_tenant_name       = undef,
  $nova_admin_auth_url          = undef,
) {

  include ::manila::deps
  if $nova_api_insecure {
    warning('The nova_api_insecure parameter is deprecated, use api_insecure instead.')
  }
  if $nova_ca_certificates_file {
    warning('The nova_ca_certificates_file is deprecated, use cafile instead.')
  }
  if $nova_admin_username {
    warning('The nova_admin_username parameter is deprecated, use username instead.')
  }
  if $nova_admin_password {
    warning('The nova_admin_password parameter is deprecated, use password instead.')
  }
  if $nova_admin_tenant_name {
    warning('The nova_admin_tenant_name parameter is deprecated, use project_name instead.')
  }
  if $nova_admin_auth_url {
    warning('The nova_admin_auth_url parameter is deprecated, use auth_url instead.')
  }

  $insecure_real = pick($insecure, $nova_api_insecure)
  $cafile_real = pick($cafile, $nova_ca_certificates_file)
  $username_real = pick($username, $nova_admin_username)
  $password_real = pick($password, $nova_admin_password)
  $project_name_real = pick($project_name, $nova_admin_tenant_name)
  $auth_url_real = pick($auth_url, $nova_admin_auth_url)

  manila_config {
    'nova/insecure':                     value => $insecure;
    'nova/auth_url':                     value => $auth_url_real;
    'nova/token_auth_url':               value => $token_auth_url;
    'nova/auth_type':                    value => $auth_type;
    'nova/cafile':                       value => $cafile;
    'nova/certfile':                     value => $certfile;
    'nova/keyfile':                      value => $keyfile;
    'nova/user_domain_name':             value => $user_domain_name;
    'nova/project_domain_name':          value => $project_domain_name;
    'nova/project_name':                 value => $project_name_real;
    'nova/region_name':                  value => $region_name;
    'nova/timeout':                      value => $timeout;
    'nova/username':                     value => $username_real;
    'nova/password':                     value => $password_real, secret => true;
    }

}
