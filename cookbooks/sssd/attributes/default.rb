# nil
# default['sssd']['xxx'] = nil 


default['sssd']['domain'] = node['domain'] || 'ipa.pthl.hk'
default['sssd']['sssd_conf_sensitive'] = false

#### This is logic operator, NOT string.
default['sssd']['sudo'] = true  # this is 0 or 1, so NO single-quota or double-quota needed.
default['sssd']['ssh'] = true
default['sssd']['autofs'] = true  
default['sssd']['nsswitch'] = %w(sudoers shadow) 

# This is string, options in a conf file. QUOTATION MARK('' || "") NEEDED.
default['sssd']['conf']['cache_credentials'] = 'True'
default['sssd']['conf']['krb5_store_password_if_offline'] = 'True'
default['sssd']['conf']['ipa_domain'] = "ipa.pthl.hk"
default['sssd']['conf']['id_provider'] = "ipa"
default['sssd']['conf']['auth_provider'] = "ipa"
default['sssd']['conf']['access_provider'] = "ipa"
default['sssd']['conf']['chpass_provider'] = "ipa"
default['sssd']['conf']['ipa_hostname'] = node['fqdn']   #client.ipa.pthl.hk
default['sssd']['conf']['ipa_server'] = "ipa.ipa.pthl.hk, ipa-rep.ipa.pthl.hk"
default['sssd']['conf']['ipa_server_mode'] = 'True'
default['sssd']['conf']['krb5_keytab'] = "/etc/krb5.keytab"
default['sssd']['conf']['ldap_tls_cacert'] = "/etc/ipa/ca.crt"

# sudo
default['sssd']['sudo_conf']['sudo_provider'] = "ldap"
default['sssd']['sudo_conf']['ldap_uri'] = "ldap://ipa.ipa.pthl.hk, ldap://ipa-rep.ipa.pthl.hk"
default['sssd']['sudo_conf']['ldap_sudo_search_base'] = "ou=sudoers,dc=ipa,dc=pthl,dc=hk"
default['sssd']['sudo_conf']['ldap_sasl_mech'] = "GSSAPI"
default['sssd']['sudo_conf']['ldap_sasl_authid'] = "host/#{node['fqdn']}"
default['sssd']['sudo_conf']['ldap_sasl_realm'] = "#{default['sssd']['domain'].upcase}"  #{} expand this expression.
default['sssd']['sudo_conf']['krb5_server'] = "ipa.ipa.pthl.hk"

# autofs
default['sssd']['autofs_conf']['autofs_provider'] = "ipa"
default['sssd']['autofs_conf']['ipa_automount_location'] = "default"
# this is from debug log "cn=default,cn=automount,dc=ipa,dc=pthl,dc=hk"
default['sssd']['autofs_conf']['ldap_autofs_search_base'] = "cn=automount,dc=ipa,dc=pthl,dc=hk"

default['sssd']['filter_users'] = %w(root)
default['sssd']['filter_groups'] = ['root']

# only for Centos/rhel, which on suse it's pam-config.
default['sssd']['authconfig_params'] = '--enablesssd --enablesssdauth --enablemkhomedir --enablelocauthorize --update'
