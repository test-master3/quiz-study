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
    @latest_question = Question.order(created_at: :desc).first # ← 追加
  end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      answer_or_error = fetch_gemini_response(@question.content)
      @question.update(answer_text: answer_or_error) unless answer_or_error.start_with?("エラー：")
  
      # 💡 new画面に戻って一覧も表示させる
      redirect_to new_question_path, notice: '質問を送信し、回答を生成しました！'
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

  def fetch_gemini_response(prompt)
    api_key = ENV['GOOGLE_API_KEY']
    unless api_key
      Rails.logger.error "Gemini API Key (GOOGLE_API_KEY) is not set."
      return "エラー：APIキーが設定されていません。"
    end

    # ★★★ 修正点: モデル名を "gemini-1.5-flash" に変更 ★★★
    # このモデルは、以前のスクリーンショットで割り当てが確認できていました。
    url = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=#{api_key}"

    headers = { 'Content-Type' => 'application/json' }
    body = {
      contents: [
        {
          role: 'user',
          parts: [
            { text: prompt }
          ]
        }
      ]
      # generationConfig や safetySettings を追加することも可能です
      # "generationConfig": {
      #   "temperature": 0.9,
      #   "maxOutputTokens": 2048 # gemini-1.5-flash の最大値に合わせて調整
      # },
      # "safetySettings": [
      #   {
      #     "category": "HARM_CATEGORY_HARASSMENT",
      #     "threshold": "BLOCK_MEDIUM_AND_ABOVE"
      #   }
      # ]
    }.to_json

    Rails.logger.info "Requesting Gemini API..."
    Rails.logger.info "URL: #{url.sub(api_key, '[REDACTED_API_KEY]')}"
    Rails.logger.info "Prompt Length: #{prompt.length} characters"
    # Rails.logger.debug "Request Body: #{body}"

    begin
      response = HTTParty.post(url, headers: headers, body: body, timeout: 60)

      Rails.logger.info "Gemini API Response Code: #{response.code}"
      Rails.logger.debug "Gemini API Response Body: #{response.body}"

      if response.success?
        candidate = response.dig('candidates', 0)
        if candidate && candidate.dig('content', 'parts', 0, 'text')
          return candidate['content']['parts'][0]['text']
        elsif candidate && candidate.dig('finishReason')
          error_message = "回答の生成に成功しましたが、有効なテキストがありませんでした。Finish Reason: #{candidate['finishReason']}"
          error_message += ". Safety Ratings: #{candidate['safetyRatings'].inspect}" if candidate['safetyRatings']
          Rails.logger.warn "Gemini API Warning: #{error_message}"
          return "エラー：#{error_message}"
        else
          Rails.logger.error "Gemini API Error: Unexpected successful response structure. Body: #{response.body}"
          return "エラー：予期しないレスポンス構造です。"
        end
      else
        error_info = response.dig('error') || {}
        status = error_info.dig('status') || 'UNKNOWN_STATUS'
        message = error_info.dig('message') || '不明なエラーが発生しました。'
        
        if message.downcase.include?("quota") || message.downcase.include?("rate limit")
            Rails.logger.warn "Gemini API Quota/Rate Limit Exceeded: Status=#{status}, Message=#{message}. Full Response: #{response.body}"
        else
            Rails.logger.error "Gemini API Error: Status=#{status}, Message=#{message}. Full Response: #{response.body}"
        end
        return "エラー：#{status} - #{message}"
      end
    rescue HTTParty::Error => e
      Rails.logger.error "HTTParty Error during Gemini API call: #{e.message}"
      return "エラー：APIへの接続に失敗しました (#{e.class.name})。"
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      Rails.logger.error "Timeout Error during Gemini API call: #{e.message}"
      return "エラー：APIへの接続がタイムアウトしました。"
    rescue StandardError => e
      Rails.logger.error "Unexpected Error during Gemini API call: #{e.message}\n#{e.backtrace.join("\n")}"
      return "エラー：予期せぬ問題が発生しました。"
    end
  end
end
