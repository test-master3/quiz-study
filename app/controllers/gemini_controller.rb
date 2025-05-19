# app/controllers/gemini_controller.rb
class GeminiController < ApplicationController
  def index
    api_key = ENV['GOOGLE_API_KEY']
    prompt = "こんにちは！簡単な挨拶を作ってください。"

    response = HTTParty.post(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=#{api_key}",
      headers: { 'Content-Type' => 'application/json' },
      body: {
        contents: [
          { role: 'user', parts: [ { text: prompt } ] }
        ]
      }.to_json
    )

    if response.success?
      @response_text = response['candidates'][0]['content']['parts'][0]['text']
    else
      @response_text = "エラー：#{response['error']['message'] || '予期しないエラー'}"
    end
  end
end