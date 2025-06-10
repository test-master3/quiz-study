# spec/system/questions_spec.rb
require 'rails_helper'

RSpec.describe "質問の投稿", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
    visit new_question_path
  end

  context "フォームの送信" do
    it "送信ボタンで質問を投稿できる" do
      within("#question_form_container") do
        fill_in "question[content]", with: "これはテストの質問です"
        click_button "送信"
      end
      expect(page).to have_content("これはテストの質問です")
    end

    it "Ctrl+Enterで質問を投稿できる", js: true do
      within("#question_form_container") do
        fill_in "question[content]", with: "これはCtrl+Enterのテストです"
        find("#question_content").send_keys([:control, :enter])
      end
      expect(page).to have_content("これはCtrl+Enterのテストです")
    end
  end
end