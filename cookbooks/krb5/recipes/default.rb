# Cookbook:: kerberos

Chef::Log.info("running #{cookbook_name}::#{recipe_name} ")

# isntall kerberos

case node['platform_family']

when 'rhel', 'centos'
  # need to figure out the exact list.
  package %w(krb5-workstation krb5-libs) do 
    action :install
  end 

when 'suse'
  # need to figure out the exact list.
  package %w(krb5 krb5-client) do 
    action :install

  end

end 

%w(/etc/krb5.conf.d /var/lib/sss/pubconf/krb5.include.d /etc/ipa).each do |path|
  directory path do
  owner 'root'
  group node['root_group']
  mode '0755'
  recursive  true 
  action :create

  end 

end


# /etc/krb5.conf
template '/etc/krb5.conf' do
  source 'krb5.conf.erb'
  owner 'root'
  group node['root_group']
  mode '0644'

  #	  variables({
  #     	:var1: value1,
  #		:var2: value2,
  # 	  })

  # we don't need to start krb5 on client-side, handled by sssd.
  
end

cookbook_file '/etc/krb5.keytab' do
  # CLIENT's keytab, like 'xxx.ZZZ.com.keytab'
  # why lazy? see https://serverfault.com/questions/604719/chef-recipe-order-of-execution-redux
  source lazy {"#{node['fqdn']}.keytab" }
  owner 'root'
  group node['root_group']
  mode '0644'
  action :create
  # don't overwrite it.
  not_if "test -f /etc/krb5.keytab" 

end

