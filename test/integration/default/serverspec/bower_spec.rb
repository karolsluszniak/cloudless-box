require 'spec_helper'

describe 'bower' do
  describe command('bower -v') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^[\w\.]+$/ }
  end
end
