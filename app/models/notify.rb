class Notify
  def self.send(tag, title, message)
    HTTParty.post(url, {
                    body: {
                      title: title,
                      format: "markdown",
                      type: "info",
                      tag: tag,
                      body: message
                    },
                    basic_auth: {
                      username: Rails.application.credentials.apprise[:username],
                      password: Rails.application.credentials.apprise[:password],
                    }
                  })
  end

  def self.url
    "#{Rails.application.credentials.apprise[:url]}/#{Rails.application.credentials.apprise[:key]}"
  end
end
