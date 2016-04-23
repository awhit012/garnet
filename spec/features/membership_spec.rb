require 'rails_helper'

RSpec.feature 'Taking Attendance', js: true do
  before(:all) do
    load "#{Rails.root}/db/seeds/test_seed.rb"
  end

  given(:cohort_under_test) { Cohort.find_by(name: 'WDIDC7') }
  given!(:test_instructor) do
    instructor = User.create!(:username => 'TEST_INSTRUCTOR', :password => 'password')
    cohort_under_test.add_member(instructor, true)
    instructor
  end

  scenario "view membership page" do
    # Given
    login_user(test_instructor)
    # visit cohort show, with expanded Attendance section
    membership = cohort_under_test.memberships.select{|m| m.user == test_instructor}
    visit membership_path(membership)

    expect(page).to have_css(".membership")

  end
end
