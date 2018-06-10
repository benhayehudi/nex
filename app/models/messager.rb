require 'nexmo'

class Messager < ApplicationRecord

  def self.send_message(number, message)
    client = Nexmo::Client.new(api_key: ENV['api_key'], api_secret: ENV['api_secret'])
    response = client.sms.send(
      from: '12013814794', 
      to: number, 
      text: message, 
      type: 'unicode'
    )
    if response.messages.first.status == '0'
      puts "Sent message id=#{response.messages.first.message_id}" 
    else 
      puts "Error: #{response.messages.first.error_text}"
    end
  end
end
