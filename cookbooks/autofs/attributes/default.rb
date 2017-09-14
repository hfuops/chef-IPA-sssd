# support LDAP.
default['autofs']['BASE_DN'] = "dc=ipa,dc=pthl,dc=hk"
default['autofs']['fqdn'] = node['fqdn']
# disable krb5 auth
default['autofs']['krb5'] = false
default['autofs']['domain'] = node['domain'] 

