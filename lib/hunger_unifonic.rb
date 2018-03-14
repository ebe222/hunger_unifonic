require 'uri'
require 'net/http'
module HungerUnifonic
  def self.send_sms(credentials, mobile_number, message,sender,options = nil)
    username = credentials['username']
    password = credentials['password']
    mobile = mobile_number.gsub(/[^a-z,0-9]/, "")
    url = URI("#{credentials['server']}/sendSms?userid=#{username}&password=#{password}&to=#{mobile}&from=#{sender}&format=json&messageBodyEncoding=UTF8&msg=#{message}")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    puts response.read_body
    if response.code.to_i.in? 200..299 && response.body[0] == "Success"
      message_id = response.body[3]
      return {message_id: message_id , code: 0}
    else
      return {error: response.body, code: response.code.to_i}
    end
  end
end

