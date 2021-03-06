class Teacher < ActiveRecord::Base
  belongs_to :user
  has_many :teacher_languageships
  has_many :languages, through: :teacher_languageships
  has_many :available_sections
  has_many :appointments
  has_many :evaluations, as: :evaluatable
  has_many :experiences
  has_many :certificates
  has_many :educations
  has_many :orders
  has_many :appointments
  accepts_nested_attributes_for :teacher_languageships, allow_destroy: true
  accepts_nested_attributes_for :languages, allow_destroy: true
  accepts_nested_attributes_for :experiences, allow_destroy: true
  accepts_nested_attributes_for :certificates, allow_destroy: true
  accepts_nested_attributes_for :educations, allow_destroy: true

  def uniq_language
    array = []
    params[:teacher][:languages_attributes].map { |x| array << x[:language] }
    array.uniq
  end

  def youtube_website
    youtube.split("=").last
  end

  def one_fee_exchange_to(iso_to)

    Money.new(one_fee*100, "USD").exchange_to(iso_to)
  end

  def five_fee_exchange_to(iso_to)
    Money.new(five_fee*100, "USD").exchange_to(iso_to)
  end

  def ten_fee_exchange_to(iso_to)
    Money.new(ten_fee*100, "USD").exchange_to(iso_to)
  end

  # def check_fee(fee,session)
  #   fee = (fee.to_i)/(session.to_i)
  #
  #   if fee == self.one_fee || fee == self.five_fee || fee == self.ten_fee
  #     return true
  #   else
  #     return false
  #   end
  # end

  # def hangouts_url
  #   if self.hangouts_url.blank?

  #     charset = (0...4).map { ('a'..'z').to_a[ rand(26)] }.join
  #     url =  "https://talkgadget.google.com/hangouts/_/i"+charset+"m5jzffaheagjkaa5wzj7y2?hl=zh-TW"
  #     self.hangouts_url = url
  #   end
  # end

  def appointment_check(start_time, end_time)
    self.appointments.where("(start >= ? and end <= ?) or (start >= ?  and start < ?) or (end > ?  and end <= ?) or (start < ? and end > ?)",
                            start_time, end_time,
                            start_time, end_time,
                            start_time, end_time,
                            start_time, end_time).exists?
  end

  def find_available_days
    @days = []
    self.available_sections.each do |available_section|
      @start = available_section.start
      @end = available_section.end
      for i in 0..((@end - @start)/1.day).to_i
        @days << @start + i.days
      end
    end
    @days.select{|x| x>= Time.current.in_time_zone + 1.hours }.map{|x|x.to_date}.uniq.sort
    # @available_section_times.uniq.sort.select{|x| [x[0],x[1]] if x[0]>= Time.current.in_time_zone+12.hours }
  end

  def find_available_times(pickedday= Time.current.in_time_zone,section=2)
    @available_section_times = []
    @pickedday = pickedday.to_date.in_time_zone
    @pickedday_start = @pickedday.beginning_of_day
    @pickedday_end = @pickedday.end_of_day
    # type 要輸入1 or 2 試上 或正式課
    available_sections.each do |available_section|
      for i in 0..((available_section.end - available_section.start) / 24.hours).to_i+1
        @forday = available_section.start.to_date + i.days
        if @forday == @pickedday.to_date
          if available_section.start >= @pickedday_start && available_section.start < @pickedday_end && available_section.end > @pickedday_end
            block = (((@pickedday_end + 1) - available_section.start) / 30.minute).to_i - 1
            x = available_section.start
          end
          if available_section.start <  @pickedday_start && available_section.end > @pickedday_end
            block = (((@pickedday_end + 1) - @pickedday_start) / 30.minute).to_i - 1
            x = @pickedday_start
          end

          if available_section.end > @pickedday_start && available_section.end <= @pickedday_end && available_section.start < @pickedday_start
            block = ((available_section.end - @pickedday_start) / 30.minute).to_i - 1
            x = @pickedday_start
          end
          if available_section.start >= @pickedday_start && available_section.end < @pickedday_end
            block = ((available_section.end - available_section.start) / 30.minute).to_i - 1
            x = available_section.start
          end
          unless block.nil?
            for i in 0..block
              @available_section_times << [ x , x + (section* 30.minute)]
              x += 30.minute
            end
          end
          # if @available_section_times.present?
          # @available_section_times.pop if @available_section_times.last.last > available_section.end
          #   end
          @available_section_times.pop if section == 2 && block != nil
        end
      end
    end
    @available_section_times.uniq.select{|x| x unless self.appointment_check(x[0], x[1])}.sort.select{|x| x[0]>= Time.current.in_time_zone + 1.hours}.map{|x| x[0].strftime('%R %p')+" - "+x[1].strftime('%R %p') }
  end
  # @available_section_times.uniq.select{|x| x unless self.appointment_check(x[0], x[1])}.sort.select{|x| x[0]>= Time.current.in_time_zone+12.hours }.map{|x| x[0].strftime('%r')+" - "+x[1].strftime('%r') }
end
