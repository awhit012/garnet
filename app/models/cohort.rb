class Cohort < ActiveRecord::Base
  has_many :events
  has_many :attendances, through: :events

  has_many :assignments
  has_many :submissions, through: :assignments

  has_many :memberships, dependent:  :destroy
  has_many :admin_memberships, -> { where(is_admin: true) }, class_name: 'Membership'
  has_many :nonadmin_memberships, -> { where(is_admin: false) }, class_name: 'Membership'
  alias_method :student_memberships, :nonadmin_memberships

  # through memberships
  has_many :admins, through: :admin_memberships, :source => :user
  alias_method :instructors, :admins
  has_many :nonadmins, through: :nonadmin_memberships, :source => :user
  alias_method :students, :nonadmins
  has_many :observations, through: :memberships
  has_many :users, through: :memberships

  # we use this to only show existing tags on the cohort tag form. The unique
  # is important becuase otherwise we'll get duplicates of tags
  has_many :existing_tags, -> {uniq},  through: :memberships, source: :tags

  belongs_to :course
  belongs_to :location

  scope :active, -> {where("end_date >= ?", Time.now)}
  scope :inactive, -> {where("end_date < ?", Time.now)}

  def has_admin? user
    self.admins.include?(user)
  end

  def add_admin(user)
    self.memberships.create!(user: user, is_admin: true)
  end

  def add_member(user, is_admin = false)
    self.memberships.create!(user: user, is_admin: is_admin)
  end

  def tags
    self.memberships.map { |m| m.tags }.flatten.uniq
  end

  def self.to_csv(memberships)
    CSV.generate({}) do |csv|
      csv << ["User Name", "Percent Present", "Percent Tardy", "Percent Absent", "Percent HW Complete", "Percent HW Incomplete","Percent HW Missing"]
      memberships.each do |membership|
        csv << [
	  membership.name,
	  membership.percent_from_status(:attendances, Attendance.statuses[:present]),
	  membership.percent_from_status(:attendances, Attendance.statuses[:tardy]),
	  membership.percent_from_status(:attendances, Attendance.statuses[:absent]),
	  membership.percent_from_status(:submissions, Submission.statuses[:complete]),
	  membership.percent_from_status(:submissions, Submission.statuses[:incomplete]),
	  membership.percent_from_status(:submissions, Submission.statuses[:missing])
	]
      end
    end
  end

  def generate_events start_time, time_zone
    # grabs offset leveraging current time of timezone passed in
    # have to offset to accomodate for UTC, config timezone doesn't set "server time", rails always stores dates in UTC in the database
    offset = ActiveSupport::TimeZone[time_zone].now.to_s.split(' ').last
    days_in_cohort = (end_date - start_date).to_i
    current_day_time = start_date.to_datetime.change({hour: start_time, offset: offset })
    # TODO: refactor using business_time gem to stream line all of this using matt's psuedocode
      # gather workdays between start/end date
      # reject dates that have existing events
      # loop thru remaining dates, create events based on those dates

    days_in_cohort.times do |i|
      current_day_time += 1.day
      # if current day is a weekday .wday will return a number between 1-5
      if current_day_time.wday < 6 && current_day_time.wday > 0
        # sees if there's an event that has the same day and month as the current day
        if !self.events.any?{|event| event.occurs_at.to_date == current_day_time.to_date}
          self.events.create(occurs_at: current_day_time, title: current_day_time.strftime("%B %d, %Y"))
        end
      end
    end
    return self.events
  end
end
