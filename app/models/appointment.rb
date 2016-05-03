class Appointment < ActiveRecord::Base
  belongs_to :user
  belongs_to :teacher
  has_many :evalutions
  has_many :available_section

  def book_section
    [:start, :end].join('~')
  end

  def book_section=(sections)
    split = sections.split('~', 2)
    self.start = split.first.to_time
    self.end = split.last.to_time
  end


  def self.appointment_check(start_time, end_time, teacher_id)
    # 被包含在內 (start => ? and end <= ?)
    # 開始時間在內 (start > ?  and start < ?)
    # 結束時間在內 (end > ?  and end < ?)
    # 整個時段被包含在某一個預約時間內(start < ? and end > ?)
    # Appointment.where("((start between ? and ?) OR (end between ? and ?)) AND teacher_id = ?",
    #                        start_time, end_time,
    #                        start_time, end_time,
    #                        teacher_id).exists?
    Appointment.where("((start >= ? and end <= ?) or (start >= ?  and start < ?) or (end > ?  and end <= ?) or (start < ? and end > ?)) AND teacher_id = ?",
                      start_time, end_time,
                      start_time, end_time,
                      start_time, end_time,
                      start_time, end_time,
                      teacher_id).exists?
  end

  def self.create_appointment(start_time, end_time, teacher, student)
    Appointment.create!(:start => start_time,
                        :end => end_time,
                        :teacher => teacher,
                        :user => student,
                        :section => (end_time - start_time) / 30.minute)
  end

  def self.booked_section(teacher_id)
    where('teacher_id=? and end > ? and start < ?',
          teacher_id,
          Time.now.to_time.at_beginning_of_day,
          14.days.from_now.to_time.at_end_of_day)
  end
end
