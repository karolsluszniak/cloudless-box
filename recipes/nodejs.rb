url = 'https://rpm.nodesource.com/setup_4.x'
bin_dir = '/bin'

bash 'install nodejs' do
  code [
    "curl --silent --location #{url} | bash -",
    "yum install -y nodejs"
  ].join(' && ')
  creates "#{bin_dir}/node"
end
