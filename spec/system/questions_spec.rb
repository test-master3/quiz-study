require 'rails_helper'

RSpec.describe "質問機能", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in user
  end

  describe "質問の新規作成" do
    context "正常な入力の場合" do
      it "質問を投稿できること" do
        visit new_question_path
        expect(page).to have_selector("#question_content")
        fill_in "question[content]", with: "これはテストの質問です"
        click_button "送信"
        expect(page).to have_content("質問が投稿されました！")
      end
    end

    context "空の入力の場合" do
      it "エラーメッセージが表示されること" do
        visit new_question_path
        expect(page).to have_selector("#question_content")
        fill_in "question[content]", with: ""
        click_button "送信"
        expect(page).to have_content("Content can't be blank")
      end
    end
  end
end 