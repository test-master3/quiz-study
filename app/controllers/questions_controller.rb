# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:new]
  before_action :set_question, only: [:show, :save_quiz_and_answer]

  def index
    @questions = Question.order(created_at: :desc)
  end

  def show
    # @question は set_question で設定されます
  end

  def new
    @question = Question.new
    if user_signed_in?
      @questions = current_user.questions.order(created_at: :desc)
    else
      @questions = []
    end
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
  
  def save_quiz_and_answer
  # Quiz保存
  quiz = Quiz.create!(
    user: @question.user,
    question: @question,
    quiz_text: @question.quiz_question,
    send_to_line: true

   )

  # Answer保存
  Answer.create!(
    user: @question.user,
    quiz: quiz,
    question_id: @question.id,
    content: @question.answer_text,
  )

  redirect_to questions_path, notice: "クイズと回答を保存しました！"
end

private

  # idを元に@questionを設定する共通メソッド
  def set_question
    @question = Question.find(params[:id])
  end

  # フォームから安全なデータだけを受け取るための「門番」メソッド
  def question_params
    params.require(:question).permit(:content)
  end

  # Gemini APIを呼び出すメソッド（完成版）
  def fetch_quiz_and_answer(prompt)
    # サービスアカウントJSONのパスなど、クライアントを作成
    keyfile_path = Rails.root.join("config/credentials/vertex-key.json")
    # ※ もしinitializersに移動させていたら、この部分は不要かもしれません
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(keyfile_path),
      scope: "https://www.googleapis.com/auth/cloud-platform"
    )
    client = Google::Cloud::AIPlatform::V1::PredictionService::Client.new do |config|
      config.credentials = credentials
      config.endpoint = "asia-northeast1-aiplatform.googleapis.com"
    end

    # AIに送るプロンプトを作成
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
  
    # APIに送るリクエストを作成
    project_id = ENV["VERTEX_PROJECT_ID"] # 新しいプロジェクトIDが設定されているか確認
    location = "asia-northeast1"
    model = "gemini-1.5-flash-002" # 正しいモデル名
    model_name = "projects/#{project_id}/locations/#{location}/publishers/google/models/#{model}"
    
    request = {
      model: model_name,
      contents: [{ role: "user", parts: [{ text: full_prompt }] }],
      tools: [{ google_search_retrieval: {} }]
    }

    # APIを呼び出し、生の回答を取得
    response = client.generate_content(request)
    text = response.candidates.first.content.parts.first.text
    Rails.logger.info "==== RAW GEMINI RESPONSE START ====\n#{text}\n==== RAW GEMINI RESPONSE END ===="
    return { answer_text: "エラー：Geminiからの応答がありませんでした。", quiz_question: "", quiz_choices: "", quiz_answer: "" } unless text.present?

    # パース処理
    begin
      answer_match = text.match(/回答:(.*?)クイズ:/m)
      quiz_match = text.match(/クイズ:(.*?)選択肢:/m)
      choices_match = text.match(/選択肢:(.*?)正解:/m)
      correct_match = text.match(/正解:(.*)/)

      raise "Required part of the response was not found." unless answer_match && quiz_match && choices_match && correct_match
      
      # パース成功時
      {
        answer_text: answer_match[1].strip,
        quiz_question: quiz_match[1].strip,
        quiz_choices: choices_match[1].strip,
        quiz_answer: correct_match[1].strip
      }
    rescue => e
      # パース失敗時（フォールバック）
      Rails.logger.error "Could not parse Gemini response. Falling back to raw text. Error: #{e.message}"
      {
        answer_text: text,
        quiz_question: "（クイズの分解に失敗しました）",
        quiz_choices: "",
        quiz_answer: ""
      }
    end
  end
end