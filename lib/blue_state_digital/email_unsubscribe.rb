module BlueStateDigital
  class EmailUnsubscribe < ApiDataModel
    attr_accessor :email, :reason

    def unsubscribe!
      result = connection.perform_request '/cons/email_unsubscribe', {email: email, reason: reason}, 'POST'
      result == ''
    end
  end
end

