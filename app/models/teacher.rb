class Teacher < ActiveRecord::Base
  belongs_to :user

  has_many :teacher_languageships
  has_many :languages, through: :teacher_languageships

  has_many :appointments
  has_many :evaluations, :as => :evaluatable

  has_many :experiences
  has_many :certificates
  has_many :educations

  has_many :orders
  has_many :appointments
  accepts_nested_attributes_for :teacher_languageships , allow_destroy: true
  accepts_nested_attributes_for :languages , allow_destroy: true
  accepts_nested_attributes_for :experiences , allow_destroy: true
  accepts_nested_attributes_for :certificates , allow_destroy: true
  accepts_nested_attributes_for :educations , allow_destroy: true


  def uniq_language
    array = []
    params[:teacher][:languages_attributes].map { |x| array << x[:language] }
    array.uniq
  end

  def youtube_website
    youtube.split("=").last
  end

  def one_fee_exchange_to(iso_to)
    Money.new(one_fee, "USD").exchange_to(iso_to)
  end

  def five_fee_exchange_to(iso_to)
    Money.new(five_fee, "USD").exchange_to(iso_to)
  end

  def ten_fee_exchange_to(iso_to)
    Money.new(ten_fee, "USD").exchange_to(iso_to)
  end

  # def hangouts_url
  #   if self.hangouts_url.blank?

  #     charset = (0...4).map { ('a'..'z').to_a[ rand(26)] }.join
  #     url =  "https://talkgadget.google.com/hangouts/_/i"+charset+"m5jzffaheagjkaa5wzj7y2?hl=zh-TW"
  #     self.hangouts_url = url
  #   end
  # end








end
