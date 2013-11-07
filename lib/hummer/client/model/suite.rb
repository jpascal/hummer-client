class Hummer::Client::Model::Suite < Hummer::Client::Model::Base
  attributes :id, :project_id, :build, :total_tests, :total_errors, :total_failures, :total_skip, :total_passed, :feature_list, :user_name
  resource "suites"
  def project
    Hummer::Client::Model::Project.find(project_id)
  end
  def self.save(project, build, feature_list, file)
    @@server["projects/#{project}/suites"].post({
          :tempest => File.open(file),
          :build => build,
          :feature_list => feature_list,
          :multipart => true
    })
  rescue => e
    puts "API error: #{e.message}"
    exit(1)
  end
end
