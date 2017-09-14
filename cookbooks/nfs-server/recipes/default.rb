# isntall nfs related packages.
# ONLY TEST ON SLES12-SP2.

case node['platform_family']

when 'rhel', 'centos'
  # TO DO, need to figure out the eactl package list.
  package %w(a b c ) do 
    action :install
  end

when 'suse'

  package %w(nfsidmap nfs-client nfs-kernel-server) do 
    action :install
  end

end 

  directory "#{node['nfs']['share']}" do
  owner 'root'
  group node['root_group']
  mode '0755'
  recursive true 
  action :create 

  not_if {::File.exist?("#{node['nfs']['share']}")}

  end

case node['platform_family'] 

when 'suse' 
  template '/etc/sysconfig/nfs' do
    source 'nfs-suse.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    # will we log sensitive data in chef-client run, default is false, also applies to excute, file resources.
  
   # notifies :restart, 'service[nfsserver]'
  end

  template '/etc/idmapd.conf' do
    source 'idmapd.conf.erb'
    owner 'root'
    group node['root_group']

  end

  template '/etc/exports' do
    source 'exports.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    notifies :restart, 'service[nfs-idmapd]'
    notifies :restart, 'service[rpc-svcgssd]'
    notifies :restart, 'service[nfsserver]'
  
  end


when 'centos', 'rhel'
  template '/etc/sysconfig/nfs' do
    source 'nfs-rh.erb'
    owner 'root'
    group node['root_group']
    mode '0600'
    # I don't know the exactl names on Redhat/Centos.
    # This is just a placeholder.
    notifies :restart, 'service[nfsserver]'
    notifies :restart, 'service[nfs-idmapd]'
    notifies :restart, 'service[rpc-svcgssd]'
    
  end
end 

service 'nfsserver' do
  supports status: true, restart: true, reload: true
  #action [:enable, :start]
  action :nothing
end

service 'nfs-idmapd' do
  supports status: true, restart: true, reload: true
  #action [:enable, :start]
  action :nothing
end

service 'rpc-svcgssd' do
  supports status: true, restart: true, reload: true
  #action [:enable, :start]
  action :nothing
  # this is for krb5 auth, support by NFS V4.
  only_if { node['nfs']['krb5'] }

end 
