require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    @user = FactoryBot.build(:user)
  end
  context 'ユーザー新規登録ができるとき' do 
    it '正しい情報を入力すればユーザー新規登録ができてトップページに移動する' do
      # トップページに移動する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがあることを確認する
      expect(page).to have_content('新規登録')
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: @user.password
      fill_in 'パスワード（確認用）', with: @user.password
      # サインアップボタンを押すとユーザーモデルのカウントが1上がることを確認する
      expect{
        click_button '新規登録'
        sleep 1
      }.to change { User.count }.by(1)
      # トップページへ遷移することを確認する
      expect(page).to have_current_path(root_path)
      # ログインボタンが表示されていないことを確認する
      expect(page).to have_content('ログアウト')
      # 新規登録ボタンが表示されていないことを確認する
      expect(page).to have_no_content('新規登録')
    end
  end

  context 'ユーザー新規登録ができないとき' do
    it '誤った情報では新規登録ができずに新規登録ページへ戻ってくる' do
      # トップページに移動する
      visit root_path
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # 不正な情報を入力する
      fill_in 'メールアドレス', with: ''
      fill_in 'パスワード', with: ''
      fill_in 'パスワード（確認用）', with: ''
      # 新規登録ボタンを押してもユーザーモデルのカウントは上がらない
      expect{
        click_button '新規登録'
        sleep 1
      }.to change { User.count }.by(0)
      # 新規登録ページに戻される
      expect(page).to have_current_path(new_user_registration_path)
      # エラーメッセージが表示される
      expect(page).to have_content('メールアドレスを入力してください')
      expect(page).to have_content('パスワードを入力してください')
    end

    it '既存のメールアドレスでは登録できない' do
      # 既存のユーザーを作成
      @existing_user = FactoryBot.create(:user)
      # トップページに移動する
      visit root_path
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # 既存のユーザーと同じメールアドレスを入力
      fill_in 'メールアドレス', with: @existing_user.email
      fill_in 'パスワード', with: @user.password
      fill_in 'パスワード（確認用）', with: @user.password
      # 新規登録ボタンを押してもユーザーモデルのカウントは上がらない
      expect{
        click_button '新規登録'
        sleep 1
      }.to change { User.count }.by(0)
      # 新規登録ページに戻される
      expect(page).to have_current_path(new_user_registration_path)
      # エラーメッセージが表示される
      expect(page).to have_content('メールアドレスはすでに存在します')
    end
  end
end

RSpec.describe 'ログイン', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'ログインができるとき' do
    it '保存されているユーザーの情報と合致すればログインができる' do
      # トップページに移動する
      visit root_path
      # ログインページへ遷移する
      visit new_user_session_path
      # 正しい情報を入力する
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: @user.password
      # ログインボタンを押す
      click_button 'ログイン'
      sleep 1
      # トップページへ遷移することを確認する
      expect(page).to have_current_path(root_path)
      # ログアウトボタンが表示されることを確認する
      expect(page).to have_content('ログアウト')
      # 新規登録ボタンが表示されていないことを確認する
      expect(page).to have_no_content('新規登録')
    end
  end

  context 'ログインができないとき' do
    it '保存されているユーザーの情報と合致しないとログインができない' do
      # トップページに移動する
      visit root_path
      # ログインページへ遷移する
      visit new_user_session_path
      # 誤った情報を入力する
      fill_in 'メールアドレス', with: ''
      fill_in 'パスワード', with: ''
      # ログインボタンを押す
      click_button 'ログイン'
      sleep 1
      # ログインページへ戻されることを確認する
      expect(page).to have_current_path(new_user_session_path)
      # エラーメッセージが表示される
      expect(page).to have_content('メールアドレスまたはパスワードが違います')
    end

    it '誤ったパスワードではログインできない' do
      # トップページに移動する
      visit root_path
      # ログインページへ遷移する
      visit new_user_session_path
      # メールアドレスは正しいが、パスワードが誤っている情報を入力する
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: 'wrong_password'
      # ログインボタンを押す
      click_button 'ログイン'
      sleep 1
      # ログインページへ戻されることを確認する
      expect(page).to have_current_path(new_user_session_path)
      # エラーメッセージが表示される
      expect(page).to have_content('メールアドレスまたはパスワードが違います')
    end
  end
end

RSpec.describe 'ログアウト', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  describe 'ログアウト機能' do
    # テストで使うユーザーをletで定義します
    # （もしFactoryBotを使っていなければ、@user = User.create(...) のようにしてください）
    let(:user) { FactoryBot.create(:user) }
  
    # このテストの目的は、「ログアウトという状態になった後、
    # 保護されたページにアクセスできなくなる」という
    # アプリケーションの最も重要なセキュリティ機能を確認することに絞ります。
    it 'ログアウト後は保護されたページにアクセスできなくなる' do
      # 1. Deviseヘルパーで、確実にログイン状態にします
      login_as(user, scope: :user)
  
      # 2. ログインできていることを確認するため、一度トップページにアクセスします
      visit root_path
      # この時点で「ログアウト」ボタンが表示されているはずです
  
      # 3. UIはクリックせず、Deviseヘルパーで内部的にログアウト状態にします
      logout(:user)
  
      # 4. 保護されたページ（例：質問一覧）にアクセスを試みます
      visit questions_path
  
      # 5. ログインページにリダイレクトされていることを確認します
      expect(current_path).to eq new_user_session_path
    end
  end
end