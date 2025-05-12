# app/controllers/line_webhook_controller.rb
class LineWebhookController < ApplicationController
  protect_from_forgery except: :callback  # CSRF対策を無効化

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)

    events.each do |event|
      if event.is_a?(Line::Bot::Event::Message)
        message = {
          type: 'text',
          text: '連携ありがとうございます！'
        }
        client.reply_message(event['replyToken'], message)
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end