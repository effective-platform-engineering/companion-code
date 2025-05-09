require 'awspec'

describe route53_hosted_zone('epetech.io.') do
  it { should exist }
end

describe route53_hosted_zone('prod-i01-aws-us-east-2.epetech.io.') do
  it { should exist }
end


describe route53_hosted_zone('dev.epetech.io.') do
  it { should exist }
end

describe route53_hosted_zone('qa.epetech.io.') do
  it { should exist }
end

describe route53_hosted_zone('api.epetech.io.') do
  it { should exist }
end
