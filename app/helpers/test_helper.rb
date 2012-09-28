require 'base64'
module TestHelper
    def base64encode(data)
    	Base64.encode64(data)
    end
end
