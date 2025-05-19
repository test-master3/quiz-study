# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  before_action :set_question, only: %i[show]
  before_action :authenticate_user!, only: [:create]

  def index
    @questions = Question.order(created_at: :desc)
  end

  def show
    # @question は set_question で設定されます
  end

  def new
    @question = Question.new
    @questions = Question.order(created_at: :desc) # ← 追加
  end

# app/controllers/questions_controller.rb
# app/controllers/questions_controller.rb の create アクション (一部抜粋)
# (現在の questions_controller_rb_v2 のままで基本的にはOKのはずです)
# def create
#   @question = current_user.questions.build(question_params)

#   if @question.save
#     quiz_data = fetch_quiz_and_answer(@question.content)

#     if quiz_data.is_a?(Hash)
#       @question.update(
#         answer_text: quiz_data[:answer_text],
#         quiz_question: quiz_data[:quiz_question],
#         quiz_choices: quiz_data[:quiz_choices],
#         quiz_answer: quiz_data[:quiz_answer]
#       )

#       respond_to do |format|
#         format.turbo_stream
#         format.html { redirect_to @question, notice: '質問を送信し、回答とクイズを生成しました！' }
#       end
#     else
#       # Gemini APIでエラーが返ってきた場合（文字列で返ってくる）
#       flash.now[:alert] = "回答とクイズの生成中にエラーが発生しました。#{quiz_data}"
#       @questions = Question.order(created_at: :desc)
#       respond_to do |format|
#         format.turbo_stream {
#           render turbo_stream: turbo_stream.replace("question_form_container",
#             partial: "questions/form", locals: { question: @question })
#         }
#         format.html { render :new, status: :unprocessable_entity }
#       end
#     end
#   else
#     # バリデーションエラー
#     @questions = Question.order(created_at: :desc)
#     respond_to do |format|
#       format.turbo_stream {
#         render turbo_stream: turbo_stream.replace("question_form_container",
#           partial: "questions/form", locals: { question: @question })
#       }
#       format.html { render :new, status: :unprocessable_entity }
#     end
#   end
# end

def create
  @question = current_user.questions.build(question_params)
  if @question.save
    # Geminiから回答とクイズを取得（クイズ機能を入れている場合はこちら）
    result = fetch_quiz_and_answer(@question.content)

    if result.is_a?(Hash)
      @question.update(
        answer_text: result[:answer_text],
        quiz_question: result[:quiz_question],
        quiz_choices: result[:quiz_choices],
        quiz_answer: result[:quiz_answer]
      )
    else
      flash[:alert] = "回答生成エラー: #{result}"
    end

    # 🚨 リダイレクトで `/questions`（トップページ）に戻す
    redirect_to new_question_path, notice: "質問が投稿されました！"

  else
    @questions = Question.order(created_at: :desc)
    render :new, status: :unprocessable_entity
  end
end
  


  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:content)
  end

  def fetch_quiz_and_answer(prompt)
    api_key = ENV['GOOGLE_API_KEY']
    return "エラー：APIキーが設定されていません。" unless api_key

    url = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=#{api_key}"
    headers = { 'Content-Type' => 'application/json' }

   full_prompt = <<~PROMPT
  次の説明文に基づいて、1. 回答（100文字以上） 2. 三択クイズ を日本語で生成してください。

【説明文】
#{prompt}

【出力フォーマット】
回答: 〇〇〇
クイズ: 〇〇〇は何ですか？
選択肢:
1. 〇〇
2. 〇〇
3. 〇〇
正解: 1
PROMPT

    body = {
      contents: [
        { role: 'user', parts: [{ text: full_prompt }] }
      ]
    }.to_json

    begin
      response = HTTParty.post(url, headers: headers, body: body)
      text = response.dig('candidates', 0, 'content', 'parts', 0, 'text')

      return "エラー：Geminiからの応答がありません。" unless text

      lines = text.split("\n").map(&:strip)
      answer_line = lines.find { |l| l.start_with?("回答:") }
      quiz_line = lines.find { |l| l.start_with?("クイズ:") }
      choices = lines.select { |l| l =~ /^\d\.\s/ }
      correct = lines.find { |l| l.start_with?("正解:") }

      {
        answer_text: answer_line&.gsub("回答:", "")&.strip,
        quiz_question: quiz_line&.gsub("クイズ:", "")&.strip,
        quiz_choices: choices.join("\n"),
        quiz_answer: correct&.gsub("正解:", "")&.strip
      }
    rescue => e
      "エラー：#{e.message}"
    end
  end
end
