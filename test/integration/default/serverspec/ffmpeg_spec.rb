require 'spec_helper'

describe 'ffmpeg' do
  describe command('/usr/local/bin/ffmpeg -h') do
    its(:exit_status) { should eq 0 }
  end
end
