require 'rails_helper'
require 'rake'

RSpec.describe "Metrics", :type => :request do
  def require_rake_file(rake_file)
    Rake.application = Rake::Application.new
    loaded_files_excluding_current_rake_file = []
    # puts "Requiring rake_file: #{rake_file}"
    Rake.application.rake_require(rake_file, [Rails.root.join("lib/tasks").to_s], loaded_files_excluding_current_rake_file)
  end

  describe "brakeman" do
    let(:url_path)  { "/metrics/brakeman" }

    before(:all) do
      require_rake_file("metrics")
      # clean up
      Rake::Task['metrics:brakeman:clean'].invoke
      # generate
      Rake::Task['metrics:brakeman:generate'].invoke('false')
    end

    it "requires un-authenticated access to endpoint" do
      get url_path
      expect(response).to_not be_redirect
    end

    it "contains the brakeman html report" do
      get url_path
      expect(response.body).to match(/Brakeman Report/i)
    end
  end

  describe "sandi_meter" do
    let(:url_path)  { "/metrics/sandi_meter" }

    before(:all) do
      require_rake_file("metrics")
      # clean up
      Rake::Task['metrics:sandi_meter:clean'].invoke
      # generate
      Rake::Task['metrics:sandi_meter:generate'].invoke('false')
    end

    it "requires un-authenticated access to endpoint" do
      get url_path
      expect(response).to_not be_redirect
    end

    it "contains the sandi_meter html report" do
      get url_path
      expect(response.body).to match(/Sandi Metz rules/i)
    end
  end
end
