# only run on IPA server, add it to run_list of IPA Server.
# node.fqdn or node["ipaddress"]

# /etc/chef/secret

secret_data = Chef::EncryptedDataBagItem.load_secret("/etc/chef/secret")
creds  = Chef::EncryptedDataBagItem.load("sssd","sssd", secret_data)
password = creds["kinit_admin"] 
#ipa_client_list = creds["sssd_client"]

# discard data_bags
# search nodes that running ipa_client.
ipa_client_list = search(:node, "role:ipa_client AND tags:sssd_client")

ipa_client_list.each do |clients|
  
  client = "#{clients.name}.#{node['krb5']['domain']}"

  execute "for_#{client}" do
  # must have ticket, by "kinit admin"
  # check host is joined or not.
  command "echo #{password} | kinit admin && (ipa host-find #{client} || ipa-join -h #{client} -s #{node['krb5']['ipa-server']}  -k /opt/repos/cookbooks/#{cookbook_name}/files/default/#{client}.keytab -b #{node['krb5']['BASE_DN']})"
  sensitive true  # DO NOT display password when chef-client runs.
  ignore_failure true # Host is already joined, which might raise error. It doesn't matter.
  action :run

  # only run on IPA Server and ${client}.keytab does not exist.
  only_if {  node['krb5']['fqdn'] == node['krb5']['ipa-server'] } 
  not_if  { ::File.exist?("/opt/repos/cookbooks/#{cookbook_name}/files/default/#{client}.keytab") }

  notifies :run, 'execute[commit-keytab]', :immediately


  end

end

execute 'commit-keytab' do

   command 'knife cookbook upload krb5'
   action :nothing

end

