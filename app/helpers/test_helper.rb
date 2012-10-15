require 'base64'
module TestHelper
    def base64encode(data)
    	Base64.encode64(data)
    end

    def replace_host(value)
    	if (value == nil)
    		return nil 
    	end
        port = (request.port == 80) ? "" : (":" + request.port.to_s)
        value.gsub("{host}", request.host + port).gsub(
            "{other_host}", (request.host == APP_CONFIG["origin1"] ? APP_CONFIG["origin2"] : APP_CONFIG["origin1"]) + port
            ).gsub("{origin1}", APP_CONFIG["origin1"] + port).gsub("{origin2}", APP_CONFIG["origin2"] + port)
    end
end
