require 'line/bot'

class LineWebhookController < ApplicationController
  protect_from_forgery except: :callback

  # 連携コードの有効期間（分）
  TOKEN_VALID_FOR = 10

  def callback
    # デプロイ確認用のログ
    Rails.logger.info("✅ DEPLOY CHECK: LineWebhookController#callback called (version with ::)")

    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      # メッセージイベント以外は処理しない
      next unless event.is_a?(::Line::Bot::Event::Message)
      # テキストメッセージ以外は処理しない
      next unless event.type == ::Line::Bot::Event::MessageType::Text

      handle_message_event(event)
    end

    head :ok
  end

  private

  def client
    @client ||= ::Line::Bot::Client.new do |config|
      # 環境変数から認証情報を設定
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def handle_message_event(event)
    # 受信したメッセージ
    received_text = event.message['text']
    # 送信元のLINE User ID
    line_user_id = event['source']['userId']

    # メッセージが6桁の数字（連携コード）かチェック
    if received_text.match?(/\A\d{6}\z/)
      link_user_with_token(received_text, line_user_id, event['replyToken'])
    else
      # 連携コード以外への返信（今回は何もしない、または「？」と返すなど）
      # reply_text = "連携コードを送信してください。"
      # client.reply_message(event['replyToken'], { type: 'text', text: reply_text })
    end
  end

  def link_user_with_token(token, line_user_id, reply_token)
    # 送られてきたトークンでユーザーを検索
    user = User.find_by(line_link_token: token)

    # ユーザーが見つからない、または既に連携済みの場合
    unless user
      reply_text = "無効な連携コードです。もう一度、サイトで連携コードを確認してください。"
      client.reply_message(reply_token, { type: 'text', text: reply_text })
      return
    end

    # 連携コードが有効期限切れの場合
    if user.line_link_token_sent_at < TOKEN_VALID_FOR.minutes.ago
      reply_text = "連携コードの有効期限が切れています。お手数ですが、もう一度サイトで連携コードを再表示してください。"
      client.reply_message(reply_token, { type: 'text', text: reply_text })
      return
    end

    # ユーザー情報を更新してLINEと連携
    user.update!(
      line_uid: line_user_id,
      line_linked: true,
      line_link_token: nil, # 使用済みトークンは削除
      line_link_token_sent_at: nil
    )

    # 連携完了メッセージを返信
    reply_text = "アカウントの連携が完了しました！🎉 クイズの通知などをお送りしますので、お楽しみに！"
    client.reply_message(reply_token, { type: 'text', text: reply_text })

  rescue => e
    # エラーが発生した場合のログ出力
    Rails.logger.error "LINE連携処理でエラーが発生しました: #{e.message}"
    # 予期せぬエラーが発生したことをユーザーに通知
    reply_text = "エラーが発生しました。お手数ですが、時間をおいて再度お試しください。"
    client.reply_message(reply_token, { type: 'text', text: reply_text })
  end
end