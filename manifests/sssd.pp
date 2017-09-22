class profile::sssd (
  $ldap_default_bind_dn = hiera('ldap_default_bind_dn'),
  $ldap_default_authtok = hiera('ldap_default_authtok'),
  $auth_provider = hiera('auth_provider'),
  $ldap_user_uid_number = hiera('ldap_user_uid_number'),
  $ldap_user_gid_number = hiera('ldap_user_gid_number'),
  $ldap_group_gid_number = hiera('ldap_group_gid_number'),
  $ldap_group_object_class = hiera('ldap_group_object_class'),
  $ldap_user_object_class = hiera('ldap_user_object_class'),
  $ldap_default_authtok_type = hiera('ldap_default_authtok_type'),
  $ldap_tls_cacert          = hiera('ldap_tls_cacert'),
  $ldap_tls_cacert_basename = hiera('ldap_tls_cacert_basename'),
  $default_shell = hiera('default_shell'),
  $fallback_homedir = hiera('fallback_homedir'),
  $krb5_server = hiera('krb5_server'),
  $krb5_backup_server = hiera('krb5_backup_server'),
  $krb5_realm = hiera('krb5_realm'),
  $krb5_auth_timeout = hiera('krb5_auth_timeout'),
) {
    class { '::sssd':
      ldap_base                => hiera('ldap_search_base'),
      ldap_schema              => hiera('ldap_schema'),
      ldap_enumerate           => hiera('enumerate'),
      ldap_uri                 => hiera('ldap_uri'),
      ldap_access_filter       => hiera('ldap_access_filter'),
      ldap_group_member        => hiera('ldap_group_member'),
      ldap_tls_reqcert         => hiera('ldap_tls_reqcert'),
    }
    file { '/etc/sssd/conf.d':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0711',
    }
    file { '/etc/sssd/conf.d/ldapbind.conf':
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('profile/ldapbind.conf.erb'),
    }
    file { "${ldap_tls_cacert}":
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => hiera('keyfile'),
    }
    if $operatingsystem == 'Ubuntu' {
      file { '/etc/pam.d/common-session': 
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source => 'puppet:///modules/profile/common-session', 
     }
    }

    Class['::sssd::install'] -> Class['::sssd::config'] -> File['/etc/sssd/conf.d'] -> File['/etc/sssd/conf.d/ldapbind.conf'] ~> Class[::sssd::service]  
}
