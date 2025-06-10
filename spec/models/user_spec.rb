require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it 'メールアドレスとパスワードがあれば有効であること' do
      user = build(:user, email: 'test@example.com', password: 'password')
      expect(user).to be_valid
    end

    it 'メールアドレスがなければ無効であること' do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'パスワードがなければ無効であること' do
      user = build(:user, password: nil)
      user.valid?
      expect(user.errors[:password]).to include("can't be blank")
    end

    it '重複したメールアドレスなら無効であること' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      user.valid?
      expect(user.errors[:email]).to include("has already been taken")
    end

    context 'LINE UIDのバリデーション' do
      it '一意なLINE UIDは有効であること' do
        user = build(:user, line_uid: 'unique_line_uid')
        expect(user).to be_valid
      end

      it '重複したLINE UIDは無効であること' do
        create(:user, line_uid: 'duplicate_line_uid')
        user = build(:user, line_uid: 'duplicate_line_uid')
        user.valid?
        expect(user.errors[:line_uid]).to include("has already been taken")
      end

      it 'LINE UIDがnilでも有効であること' do
        user = build(:user, line_uid: nil)
        expect(user).to be_valid
      end
    end
  end
end 