module HungerUnifonic
  def self.send_sms(credentials, mobile_number, message,sender,options = nil)
    if credentials[:appsid].present?
      return send_by_appsid(credentials, mobile_number, message,sender,options)
    end

    connection = Faraday.new(:url => credentials[:server]) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
    username = credentials[:username]
    password = credentials[:password]
    mobile = mobile_number.gsub(/[^a-z,0-9]/, "")
    uri = URI("/mobicents/sendSms")
    params = {userid: username, password: password, to: mobile , sender: sender, format: 'json', messageBodyEncoding: 'UTF8', smscEncoding: 'UCS2', msg: message}
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

  def self.send_by_appsid(credentials, mobile_number, message,sender,options = nil)
    # request config
    connection = Faraday.new(:url => credentials[:server]) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
    mobile = mobile_number.gsub(/[^a-z,0-9]/, "")
    
    uri = URI("/rest/SMS/Messages/Send")
    appSid = credentials[:appsid]
    msg = message.encode(Encoding::UTF_8)
    
    # request parameters
    params = {
      :Recipient => mobile,
      :Body => msg,
      :AppSid => appSid,
      :SenderID => sender,
      :Priority => 'High'
    }

    response = connection.post do |req|
      req.url uri
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = params
    end

    if response.status.to_i.in?(200..299)
      response_body = JSON.parse(response.body)
      message_id = response_body["data"]["MessageID"]
      return {message_id: message_id , code: 0}
    else
      return {error: response.body, code: response.status.to_i}
    end
  end

end

