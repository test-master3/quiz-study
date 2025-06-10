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
  end
end