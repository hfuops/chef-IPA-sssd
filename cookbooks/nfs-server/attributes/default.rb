default['nfs']['share'] = "/export/home"
default['nfs']['acl'] = "*" # e.g * means all, options will be 172.16.9.0/24 
default['nfs']['params'] = "rw,fsid=0,no_subtree_check"
# whether supports kerberos 5 auth or no, if yes, params is "sec=krb5:krb5i:krb5p
default['nfs']['krb5'] = true
