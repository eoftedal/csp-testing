class ApplicationController < ActionController::Base
  protect_from_forgery
    def results_table 
        if (!session[:results]) 
            session[:results] = {}
        end
        session[:results]
    end

    def set_result(id, value)
        results_table[id.to_s] = value
    end

    def replace_host(value)
        port = (request.port == 80) ? "" : (":" + request.port.to_s)
        value.gsub("{host}", request.host + port).gsub(
            "{other_host}", (request.host == APP_CONFIG["origin1"] ? APP_CONFIG["origin2"] : APP_CONFIG["origin1"]) + port
            ).gsub("{origin1}", APP_CONFIG["origin1"] + port).gsub("{origin2}", APP_CONFIG["origin2"] + port)
    end

end
