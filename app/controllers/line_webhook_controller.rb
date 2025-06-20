class LineWebhookController < ApplicationController
  protect_from_forgery except: :callback

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Follow
        line_user_id = event['source']['userId']
        session[:line_uid] = line_user_id

        # ID連携を促すメッセージを返信する
        message = {
          type: 'text',
          text: "アカウントの連携を開始します。下のURLからログインしてください。\n#{new_line_account_url}"
        }
        client.reply_message(event['replyToken'], message)
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end