#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

# This is base configure, and will be applied to all the nodes technically.

# /etc/hosts
if node['base']['hosts_append']

  template '/etc/hosts' do

    source 'hosts.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables ({
    ip: node['ipaddress'],
    hostname: node['fqdn'] # during some scenarios node['fqdn'] = node['hostname'],
  })

  end

else
  # append new entries.
  bash "insert_line" do
    user "root"
    code <<-EOF
    echo "172.16.234.253    susesmt.pacific-textiles.com susesmt" >> /etc/hosts
    echo "172.16.232.201    ipa.ipa.pthl.hk" >> /etc/hosts
    echo "172.16.232.202    ipa-rep.ipa.pthl.hk" >> /etc/hosts
    EOF
    not_if "grep -q 'susesmt' /etc/hosts"
  end

end

# /etc/resolv.conf

if node['resolver']['nameservers'].empty? || node['resolver']['nameservers'][0].empty?
  Chef::Log.warn("#{cookbook_name}::#{recipe_name} requires that attribute ['resolver']['nameservers'] is set.")
  Chef::Log.info("#{cookbook_name}::#{recipe_name} exiting to prevent a potential breaking change in /etc/resolv.conf.")
  return

else
    template '/etc/resolv.conf' do
    source 'resolv.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    # This syntax makes the resolver sub-keys available directly
    variables node['resolver']
  end

end

# /etc/hostname
template '/etc/hostname' do 

  source 'hostname.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
end

# we don't build NTP server, and rely on external ones.

case node['platform_family'] 

when 'centos', 'rhel'
  
  package 'ntpdate' do 
  action :install
  end 

when 'suse'
  package 'ntp' do 
  action :install
  end 
  
end 

#-------------------------

cron 'ntp_update' do
  action :create
  minute '0'
  hour '12'
  command %W{
 /usr/sbin/ntpdate -u 0.cn.pool.ntp.org 1.cn.pool.ntp.org 1 >/dev/null
  }.join(' ')
end
