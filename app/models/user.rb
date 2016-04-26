class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_one :teacher

  has_many :orders
  has_many :appointments
  has_many :user_available_sections

  def display_name
    email.split("@").first
  end

end
