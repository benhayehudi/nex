class MessagerController < ApplicationController

  def new
    @numbers = message_params[:numbers].split(",")
    @numbers.each do |num|
      sanitized_num = num.gsub(/([-() ])/, '')
      Messager.send_message(sanitized_num, message_params[:message])
    end
    render :index
  end

  private

  def message_params
    params.permit(:numbers, :message)
  end
end
