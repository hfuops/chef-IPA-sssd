# node['domain'] comes from `/etc/hosts` or DNS (test by 'hostname -f'), and will be nil if unset.
default['base']['hosts_append'] = false  # True means we don't overwrite /etc/hosts, only append lines.
default['resolver']['search'] = 'ipa.pthl.hk' 
default['resolver']['domain'] = nil
default['resolver']['nameservers'] = %w(172.16.232.201 172.16.232.202 )
default['resolver']['options'] = {}
