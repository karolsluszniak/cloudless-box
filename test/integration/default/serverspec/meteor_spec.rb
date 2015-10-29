require 'spec_helper'

describe 'meteor' do
  describe file('/usr/local/bin/meteor') do
    it { should exist }
  end
end
