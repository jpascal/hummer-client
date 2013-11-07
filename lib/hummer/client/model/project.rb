class Hummer::Client::Model::Project < Hummer::Client::Model::Base
  attributes :id, :name, :feature_list, :owner_name, :created_at, :updated_at
  resource "projects"
  def suites
    Hummer::Client::Model::Suite.all("projects/#{id}/suites")
  end
end