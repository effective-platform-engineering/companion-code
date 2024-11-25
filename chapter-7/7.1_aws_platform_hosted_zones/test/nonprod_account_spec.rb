require 'awspec'

describe route53_hosted_zone('sbx-i01-aws-us-east-1.vitalsigns.io.') do
  it { should exist }
end

describe route53_hosted_zone('preview.vitalsigns.io.') do
  it { should exist }
end
