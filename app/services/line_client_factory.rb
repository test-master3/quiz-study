require 'line/bot'

class LineClientFactory
  def self.build
    # === LINEデバッグ開始 ===
    Rails.logger.info("--- [LINE DEBUG] START ---")
    Rails.logger.info("[LINE DEBUG] defined?(Line) => #{defined?(Line)}")
    Rails.logger.info("[LINE DEBUG] defined?(::Line) => #{defined?(::Line)}")
    if defined?(::Line)
      Rails.logger.info("[LINE DEBUG] ::Line.class => #{::Line.class}")
      begin
        Rails.logger.info("[LINE DEBUG] ::Line.constants => #{::Line.constants.sort.inspect}")
        Rails.logger.info("[LINE DEBUG] defined?(::Line::Bot) => #{defined?(::Line::Bot)}")
        if defined?(::Line::Bot)
          Rails.logger.info("[LINE DEBUG] ::Line::Bot.class => #{::Line::Bot.class}")
          Rails.logger.info("[LINE DEBUG] ::Line::Bot.constants => #{::Line::Bot.constants.sort.inspect}")
        end
      rescue => e
        Rails.logger.error("[LINE DEBUG] Error inspecting ::Line: #{e.message}")
      end
    end
    Rails.logger.info("--- [LINE DEBUG] END ---")
    # === LINEデバッグ終了 ===

    Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end
end 