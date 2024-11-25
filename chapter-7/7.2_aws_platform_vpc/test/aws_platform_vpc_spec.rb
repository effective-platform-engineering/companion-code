# frozen_string_literal: true
require 'awspec'
require 'json'

tfvars = JSON.parse(File.read('./' + ENV['WORKSPACE'] + '.auto.tfvars.json'))

describe vpc(tfvars['cluster_name'] + '-vpc') do
  it { should exist }
  it { should be_available }
  its(:cidr_block) { should eq tfvars['vpc_cidr'] }
end
