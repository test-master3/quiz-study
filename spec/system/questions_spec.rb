# spec/system/questions_spec.rb
require 'rails_helper'

RSpec.describe "質問の投稿", type: :system do
  before do
    driven_by(:selenium_chrome_headless) # ← ここで明示
  end

  it "フォームに入力してEnterで質問を投稿できる", js: true do
    visit root_path

    fill_in "question_content", with: "これはテストの質問です"
    find("#question_content").send_keys(:enter)

    expect(page).to have_content("これはテストの質問です")
  end
end