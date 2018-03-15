module HungerUnifonic
  def self.send_sms(credentials, mobile_number, message,sender,options = nil)
    connection = Faraday.new(:url => credentials[:server]) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
    username = credentials[:username]
    password = credentials[:password]
    mobile = mobile_number.gsub(/[^a-z,0-9]/, "")
    uri = URI("/mobicents/sendSms")
    params = {userid: username, password: password, to: mobile , sender: sender, format: 'json', messageBodyEncoding: 'UTF8', smscEncoding: 'GSM7', msg: message}
    response = connection.get do |req|
      req.url uri.path
      req.params = params
    end
    if response.status.to_i.in?(200..299)
      message_id = response.body.gsub(/[^a-z,.:_,\-, ,^A-Z,0-9]/, "").split(',')[1].split(':')[1]
      return {message_id: message_id , code: 0}
    else
      return {error: response.body, code: response.status.to_i}
    end
  end
end

