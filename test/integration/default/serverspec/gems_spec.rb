require 'spec_helper'

describe 'gems' do
  describe package('sass') do
    it { should be_installed.by('gem') }
  end
end
