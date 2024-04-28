require 'awspec'

describe iam_role('AdminUsersRole') do
  it { should exist }
  it { should have_iam_policy('AdministratorAccess') }
end
