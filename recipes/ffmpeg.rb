url = 'http://johnvansickle.com/ffmpeg/builds/ffmpeg-git-64bit-static.tar.xz'
download_dir = "/tmp/ffmpeg-static-download"
bin_dir = '/usr/local/bin'

bash 'install ffmpeg' do
  code [
    "mkdir #{download_dir}",
    "cd #{download_dir}",
    "wget #{url}",
    "tar -xf ffmpeg-git-64bit-static.tar.xz",
    "cd *-static",
    "cp ffmpeg ffprobe #{bin_dir}"
  ].join(' && ')
  creates "#{bin_dir}/ffmpeg"
end