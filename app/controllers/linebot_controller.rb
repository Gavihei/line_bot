class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|  ##ここから
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'].include?("おばさん")
            message = {
                type: 'text',
                text: "お姉さんじゃハゲ"
            }
          elsif event.message['text'].include?("ババア")
            message = {
                type: 'text',
                text: "誰がババアじゃクソガキ！殺すぞ"
            }
          elsif event.message['text'].include?("年寄り")
            message = {
                type: 'text',
                text: "けつの穴から手突っ込んで顎ガタガタ言わせたろか"
            }
          else
            message = {
                type: 'text',
                text: event
            }
          end

          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
