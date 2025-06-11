# app/services/line_notifier.rb

require 'net/http'
require 'uri'
require 'json'

class LineNotifier
  CHANNEL_ACCESS_TOKEN = ENV['LINE_CHANNEL_ACCESS_TOKEN']

  def self.send_message(user_line_uid, message)
    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    header = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{CHANNEL_ACCESS_TOKEN}"
    }
    body = {
      to: user_line_uid,
      messages: [
        {
          type: "text",
          text: message
        }
      ]
    }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json
    response = http.request(request)
    puts response.body  # デバッグ用（本番では削除可）
  end
end