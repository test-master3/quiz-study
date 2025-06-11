class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :questions
  has_many :quizzes
  has_many :answers

  validates :line_uid, uniqueness: true, allow_nil: true
  
  def line_linked?
    line_uid.present?
  end

end
