class Suite < Hummer::Client::Model::Base
  attributes :id, :project_id, :build, :total_tests, :total_errors, :total_failures, :total_skip, :total_passed, :feature_list, :user_name
  resource "suites"
  def project
    Project.find(project_id)
  end
end
