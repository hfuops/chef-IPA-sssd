# nfs server
# I don't handle the situation of CentOS/redhat, using below.
# ipa-client-automount --server=ipa.pacific-textiles.com --location=default
case node['platform_family']

when 'suse'

  template '/etc/sysconfig/autofs' do
    source 'autofs.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    
  end 
  
  template '/etc/idmapd.conf' do
    source 'idmapd.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    
    end
  
  template '/etc/autofs_ldap_auth.conf' do
    source 'autofs_ldap_auth.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0600'
    # nfs client side.
    notifies :restart, 'service[nfs-idmapd]', :immediately
    notifies :restart, 'service[rpc-gssd]', :immediately
    notifies :restart, 'service[rpcbind]', :immediately
    notifies :restart, 'service[autofs]', :immediately

    end
# I won't handle centos/rehat. as it's quite easy, run
# ipa-client-automount --server=ipa.pacific-textiles.com --location=YOUR_LOCATION
#

end 

# Both Centos and suse are the same services listed below.
service 'autofs' do 
  action :nothing
  
end

# idmapd and rpc-gss only apply to NFS V4.
service 'nfs-idmapd' do 
  action :nothing

  only_if { node['autofs']['krb5'] }
  
end

service 'rpc-gssd' do 
  action :nothing

  only_if { node['autofs']['krb5'] }
  
end

service 'rpcbind' do 
  action :nothing
  
end
  
