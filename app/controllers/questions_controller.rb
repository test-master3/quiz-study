# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:new]
  before_action :set_question, only: [:show, :save_quiz_and_answer]

  def index
    @questions = current_user.questions.order(created_at: :desc)
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

  def create
    @question = current_user.questions.build(question_params)

    if @question.save
      # Geminiから回答とクイズを取得
      result = fetch_quiz_and_answer(@question)

      if result.is_a?(Hash) && result[:answer_text].exclude?("エラー")
        @question.update(
          answer_text: result[:answer_text],
          analogy_text: result[:analogy_text],
          quiz_question: result[:quiz_question],
          quiz_choices: result[:quiz_choices],
          quiz_answer: result[:quiz_answer]
        )
      else
        # エラーメッセージをflashに格納し、questionは保存されているのでエラーとはしない
        flash[:alert] = "回答の生成に失敗しました。時間をおいて再度お試しください。"
        # resultがHashでなかった場合や、エラー文字列を含む場合のログ出力
        Rails.logger.error "回答生成エラー: #{result}"
      end

      redirect_to new_question_path, notice: "質問が投稿されました！"

    else
      @questions = current_user.questions.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def save_quiz_and_answer
    # Quiz保存
    quiz = Quiz.create!(
      user: @question.user,
      question: @question,
      quiz_text: @question.quiz_question,
      quiz_choices: @question.quiz_choices,
      quiz_link: "https://quiz-study-ibeu.onrender.com/questions/#{@question.id}",
      send_to_line: true
     )

    # Answer保存
    Answer.create!(
      user: @question.user,
      quiz: quiz,
      question_id: @question.id,
      content: @question.answer_text,
    )

    redirect_to quizzes_path, notice: "クイズと回答を保存しました！"
  end

  def bulk_delete
    if params[:question_ids].blank?
      return redirect_to questions_path, alert: "削除する質問が選択されていません。"
    end

    questions_to_delete = current_user.questions.where(id: params[:question_ids])
    count = questions_to_delete.count
    
    if questions_to_delete.destroy_all
      redirect_to questions_path, notice: "#{count}件の質問を削除しました。"
    else
      redirect_to questions_path, alert: "質問の削除に失敗しました。"
    end
  end

  private

    # idを元に@questionを設定する共通メソッド
    def set_question
      @question = Question.find(params[:id])
    end

    # フォームから安全なデータだけを受け取るための「門番」メソッド
    def question_params
      params.require(:question).permit(:content, :abstraction_level, :analogy_genre)
    end

    # Gemini APIを呼び出すメソッド（完成版）
    def fetch_quiz_and_answer(question)
      # ▼▼▼ ここから修正 ▼▼▼
      keyfile_io = if ENV['VERTEX_CREDENTIALS_JSON']
                     # 本番環境 (Render) では環境変数から読み込む
                     StringIO.new(ENV['VERTEX_CREDENTIALS_JSON'])
                   else
                     # 開発環境ではファイルから読み込む
                     keyfile_path = Rails.root.join("config/credentials/vertex-key.json")
                     return { answer_text: "開発環境のエラー：vertex-key.json が見つかりません。" } unless File.exist?(keyfile_path)
                     File.open(keyfile_path)
                   end

      begin
        credentials = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: keyfile_io,
          scope: "https://www.googleapis.com/auth/cloud-platform"
        )
        
        client = Google::Cloud::AIPlatform::V1::PredictionService::Client.new do |config|
          config.credentials = credentials
          config.endpoint = "asia-northeast1-aiplatform.googleapis.com"
        end

        # AIに送るプロンプトを動的に組み立てる
        full_prompt = <<~PROMPT
        次のトピックや質問について、以下の3点を日本語で生成してください。
        各項目は、指示されたフォーマットを厳密に守ってください。

        【トピック・質問】
        #{question.content}

        【出力フォーマット】
        回答: 
        [以下の「回答のフォーマット」を厳密に守って、全体で200文字程度で簡潔に回答を生成してください。複雑な手順やトピックの場合は、最も重要なポイントを要約してください。]
        # 回答のフォーマット
        ◎ [回答のトピックを一言で表すタイトル]
        [トピックについての簡単な紹介文を、平易な言葉で記述]

        ◎ [具体的なポイントやコツなどをまとめた小見出し]
        [全体をまとめる、フレンドリーな締めくくりの文章]

        例え話: 
        [以下の「例え話のフォーマット」と「例え話の条件」を厳密に守って、例え話を生成してください。]
        # 例え話のフォーマット
        ◎テーマ：[「例え話の条件」で指定された「対象読者」]向け　ジャンル：[「例え話の条件」で指定された「ジャンル」]
        [テーマ]は、[身近なもの]のようなものです。
        例えば
        ・[具体的な例1]
        ・[具体的な例2]
        [テーマ]は、[要約や補足]です。
        # 例え話の条件
        ・対象読者: #{question.abstraction_level || '中学生向け'}
        ・ジャンル: #{question.analogy_genre.present? && question.analogy_genre != '指定なし' ? question.analogy_genre : '指定なし'}
        ・文字数: 100文字程度

        クイズ: 
        ◎キーワードクイズ
        [「回答」で生成したタイトル]について、[生成した「回答」の内容から、重要なキーワードを問うクイズの問題文をここに記述]
        選択肢:
        1. [20文字以内の選択肢1]
        2. [20文字以内の選択肢2]
        3. [20文字以内の選択肢3]
        正解: [正解の番号]
      PROMPT
    
        # APIに送るリクエストを作成
        project_id = ENV["VERTEX_PROJECT_ID"]
        raise "VERTEX_PROJECT_IDが設定されていません。" unless project_id.present?
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
        text = response.candidates.first&.content&.parts&.first&.text
        Rails.logger.info "==== RAW GEMINI RESPONSE START ====\n#{text}\n==== RAW GEMINI RESPONSE END ===="
        return { answer_text: "エラー：Geminiからの応答がありませんでした。" } unless text.present?

        # パース処理
        answer_match = text.match(/回答:(.*?)例え話:/m)
        analogy_match = text.match(/例え話:(.*?)クイズ:/m)
        quiz_match = text.match(/クイズ:(.*?)選択肢:/m)
        choices_match = text.match(/選択肢:(.*?)正解:/m)
        correct_match = text.match(/正解:(.*)/)

        raise "Required part of the response was not found." unless answer_match && analogy_match && quiz_match && choices_match && correct_match
        
        # パース成功時
        {
          answer_text: answer_match[1].strip,
          analogy_text: analogy_match[1].strip,
          quiz_question: quiz_match[1].strip,
          quiz_choices: choices_match[1].strip,
          quiz_answer: correct_match[1].strip
        }
      rescue => e
        # パース失敗時（フォールバック）
        Rails.logger.error "Gemini API call or parsing failed: #{e.message}"
        { answer_text: "エラー：AIとの通信中に問題が発生しました。#{e.class}" }
      end
    end
end