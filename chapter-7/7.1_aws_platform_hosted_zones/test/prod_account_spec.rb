require 'awspec'

describe route53_hosted_zone('vitalsigns.io.') do
  it { should exist }
end

describe route53_hosted_zone('prod-i01-aws-us-east-2.vitalsigns.io.') do
  it { should exist }
end


describe route53_hosted_zone('dev.vitalsigns.io.') do
  it { should exist }
end

describe route53_hosted_zone('qa.vitalsigns.io.') do
  it { should exist }
end

describe route53_hosted_zone('api.vitalsigns.io.') do
  it { should exist }
end
