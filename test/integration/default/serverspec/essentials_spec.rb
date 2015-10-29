require 'spec_helper'

describe 'essentials' do
  describe yumrepo('epel') do
    it { should exist }
  end
end
