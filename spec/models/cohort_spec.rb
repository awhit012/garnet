require 'rails_helper'

RSpec.describe Cohort do
  subject(:test_cohort) { Cohort.create!(
    name: "Test Cohort",
    start_date: DateTime.parse("1969-07-20 08:34:59"),
    end_date: DateTime.parse("1969-07-27 08:59:59")
    )
  }
  let(:start_time) { 9 }
  let(:time_zone) {"Eastern Time (US & Canada)"}
  describe "#generate_events" do

    before(:each) do
      test_cohort.events.destroy_all
    end
    it "creates events with a specified start time" do
      test_cohort.generate_events(start_time, time_zone)
      expect(test_cohort.events.sample.occurs_at.hour).to eq(start_time)
    end

    it "creates events for weekdays" do
      test_cohort.generate_events(start_time, time_zone)
      num_weekdays = 5
      num_events = test_cohort.events.length
      expect(num_events).to eq(num_weekdays)
    end

    it "does not create events for weekends" do
      test_cohort.generate_events(start_time, time_zone)
      # wday of a date time will return 0 for sunday and 6 for saturday, weekdays are 1 - 5
      weekend_events = test_cohort.events.any?{|event| event.occurs_at.wday == 0 || event.occurs_at.wday == 6}
      expect(weekend_events).to eq(false)
    end

    it "does not create duplicate events" do
      test_cohort.generate_events(start_time, time_zone)
      num_events_before_running_method_again = test_cohort.events.length
      test_cohort.generate_events(start_time, time_zone)
      num_events_after_running_method_again = test_cohort.events.length
      expect(num_events_before_running_method_again).to eq(num_events_after_running_method_again)
    end
  end

  describe "#instructors & #students" do
    let(:test_instructor) { FactoryGirl.create(:user, username: "TestInstructor1") }
    let(:test_student1) { FactoryGirl.create(:user, username: "TestStudent1") }
    let(:test_student2) { FactoryGirl.create(:user, username: "TestStudent2") }

    before(:each) do
      # add instructors and students
      test_cohort.memberships.create!(user: test_student1)
      test_cohort.memberships.create!(user: test_student2)

      test_cohort.memberships.create!(is_admin: true, user: test_instructor)
    end

    it "should extract instructors from all members" do
      expect(test_cohort.instructors).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(test_cohort.instructors.count).to eq(1)
      expect(test_cohort.instructors.first).to eq(test_instructor)
    end

    it "should extract students from all members" do
      expect(test_cohort.students).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(test_cohort.students.count).to eq(2)
      expect(test_cohort.students.first).to eq(test_student1)
    end
  end
end
