require 'rails_helper'

RSpec.describe "質問機能", type: :system do
  let(:user) { create(:user) }

  before do
    @user = FactoryBot.create(:user)
  end

  describe "質問の新規作成" do
    before do
      visit new_question_path
    end

    context "正常な入力の場合" do
      it "質問を投稿できること" do
        sign_in(@user)
        within(".question-input-form") do
          fill_in "question[content]", with: "これはテストの質問です"
          click_button "送信"
        end

        expect(page).to have_content("質問が投稿されました！")
      end
    end

    context "ログインしていない場合" do
      it "質問投稿フォームが表示されないこと" do
        visit new_question_path
        expect(page).not_to have_selector(".question-input-form")
        expect(page).to have_content("ログインが必要です")
      end
    end
  end
end