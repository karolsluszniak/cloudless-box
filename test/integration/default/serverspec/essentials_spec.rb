require 'spec_helper'

describe 'essentials' do
  describe command("yum repolist all -C | grep '^!\\?epel'") do
    its(:exit_status) { should eq 0 }
  end
end
