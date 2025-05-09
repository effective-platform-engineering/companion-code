require 'awspec'

describe iam_role('simple-teams-external-dns-sa') do
  it { should exist }
end
