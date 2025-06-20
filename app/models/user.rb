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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
      # user.image = auth.info.image # assuming the user model has an image
    end
  end

  # LINE連携トークンを生成する
  def generate_line_link_token
    loop do
      # 6桁のランダムな数字を生成
      self.line_link_token = format('%06d', SecureRandom.random_number(1_000_000))
      self.line_link_token_sent_at = Time.current
      # 他のユーザーとトークンが重複していないか確認
      break unless User.exists?(line_link_token: line_link_token)
    end
    save!
  end

end
