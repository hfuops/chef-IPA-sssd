# Cookbook:: sssd

Chef::Log.info("running #{cookbook_name}::#{recipe_name} ")


ruby_block 'modify nsswitch' do
  block do
     edit = Chef::Util::FileEdit.new '/etc/nsswitch.conf' 
     node['sssd']['nsswitch'].each do |k|
     edit.insert_line_if_no_match(/^(#{k}):/, "#{k}:   files")
     end     

     if node['sssd']['sudo']
       # Add sss to the line if it's not there.
       #edit.search_file_delete_line(/^(passwd|shadow|group|automount|sudoers)) ⇒ Object
       # match occurrences with "\0 sss"
       edit.search_file_replace(/^(passwd|shadow|group|automount|sudoers):([ \t]*(?!sss\b)\w+)*[ \t]*$/, '\0 sss')
     else
       # Remove sss from the line if it is there.
       edit.search_file_replace(/^((passwd|shadow|group|automount|sudoers):.*)\bsss[ \t]*/, '\1')
     end

     edit.write_file
    end

    action :run
    not_if "grep -q sss /etc/nsswitch"
 end

# ca.crt
cookbook_file '/etc/ipa/ca.crt' do
  source 'ca.crt'
  owner 'root'
  group node['root_group']
  mode '0644'
  action :create

#  not_if "test -f /etc/ipa/ca.crt"

  notifies :run, 'bash[update_ca]', :immediately

end

# Not sure it's necessary or not. Just in case
bash 'update_ca' do
  user 'root'
  cwd '/tmp/'
  code <<-EOF
       openssl x509 -in /etc/ipa/ca.crt -text > /etc/pki/trust/anchors/ca-bundle.crt
       update-ca-certificates
  EOF

end


# isntall sssd

case node['platform_family']

when 'rhel', 'centos'

  package %w(sssd-tools sssd-ldap sssd-krb5 sssd-ipa sssd-krb5-common sssd-ad sssd) do 
    action :install
  end

  # enable pam_sss.so
  execute 'authconfig' do
    command "authconfig #{node['sssd']['authconfig_params']}"
    action :run
    # make sure nobody didn't run pam-config before. 
    # only_if {} # ruby code
    not_if "grep pam_sss /etc/pam.d/password-auth >/dev/null 2>&1" 
  end

# /etc/ssh/ssh*_conf
template '/etc/ssh/ssh_config' do
  source 'ssh_config-centos.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  #  notifies :restart, 'service[sshd]'
  
end 

template '/etc/ssh/sshd_config' do
  source 'sshd_config-centos.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  notifies :restart, 'service[sshd]'

end


when 'suse'

  #package %w(sssd sssd-ad sssd-krb5 pam-config) do 
  #  action :install
  #end
  # packge does not support wildcard, like sssd*, confirm by https://tickets.opscode.com/browse/CHEF-4775
  execute 'sssd-install' do 
  command 'zypper -n in sssd* pam-config'
  action :run

end 

  # pam config
  execute 'pamconfig' do
    command "pam-config -a --sss --mkhomedir"
    action :run
    # make sure nobody didn't run pam-config before. 
    # only_if {} # ruby code
    not_if "grep pam_sss /etc/pam.d/common-password >/dev/null 2>&1" 
  end

# /etc/ssh/ssh*_conf
template '/etc/ssh/ssh_config' do
  source 'ssh_config-suse.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  #  notifies :restart, 'service[sshd]'
  
end 

template '/etc/ssh/sshd_config' do
  source 'sshd_config-suse.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  notifies :restart, 'service[sshd]'

end


end 

# /etc/sssd/sssd.conf
template '/etc/sssd/sssd.conf' do
  source 'sssd.conf.erb'
  owner 'root'
  group node['root_group']
  mode '0600'
  # will we log sensitive data in chef-client run, default is false, also applies to excute, file resources.
  sensitive node['sssd']['sssd_conf_sensitive']

  notifies :restart, 'service[sssd]'
  only_if { ::File.exist?('/etc/krb5.keytab') }
  
end

# ------ the end of sssd.conf --- 

service 'sshd' do
  supports status: true, restart: true, reload: true
  #action [:enable, :start]
  action :nothing
end

service 'sssd' do
  supports status: true, restart: true, reload: true
  #action [:enable, :start]
  action :nothing
end

# why we have to remove nscd? see https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/usingnscd-sssd.html
service 'nscd' do 
  action [:disable, :stop]
  #only_if 'systemctl status nscd' # nscd is avaiable
end

package 'nscd' do
  action :remove  # All excepct Debian, which is purge.
end

