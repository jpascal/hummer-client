class Project < Hummer::Client::Model::Base
  attributes :id, :name, :feature_list, :owner_name, :created_at, :updated_at
  resource "projects"
  def suites
    Suite.all("projects/#{id}/suites")
  end
end