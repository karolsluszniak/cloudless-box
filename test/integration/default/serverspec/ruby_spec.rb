require 'spec_helper'

describe 'ruby' do
  describe command('/opt/rbenv/bin/rbenv --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^rbenv/ }
  end

  describe group(:rbenv) do
    it { should exist }
  end
end
