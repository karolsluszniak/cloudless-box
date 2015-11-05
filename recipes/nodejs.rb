url = 'https://rpm.nodesource.com/setup'
bin_dir = '/bin'

bash 'install ffmpeg' do
  code [
    "curl --silent --location #{url} | bash -",
    "yum install -y nodejs"
  ].join(' && ')
  creates "#{bin_dir}/node"
end
