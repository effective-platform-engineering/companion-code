require 'awspec'

describe route53_hosted_zone('sbx-i01-aws-us-east-1.epetech.io.') do
  it { should exist }
end

describe route53_hosted_zone('preview.epetech.io.') do
  it { should exist }
end
