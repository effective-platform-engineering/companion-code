require 'awspec'

describe iam_group('NonprodServiceAccountGroup') do
  it { should exist }
  it { should have_iam_user('NonprodServiceAccount') }
end

describe iam_policy('NonprodServiceAccountGroup') do
  it { should exist }
end

describe iam_group('ProdServiceAccountGroup') do
  it { should exist }
  it { should have_iam_user('ProdServiceAccount') }
end

describe iam_policy('ProdServiceAccountGroup') do
  it { should exist }
end