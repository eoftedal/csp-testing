class ApplicationController < ActionController::Base
  protect_from_forgery

    def results_table 
        if (!session[:results]) 
            session[:results] = {}
            result = Result.new()
            result.useragent = request.env['HTTP_USER_AGENT']
            result.version = session[:version]
            result.results = ActiveSupport::JSON::encode({})
            result.save()
            session[:dbResult] = result
        end
        session[:results]
    end

    def new_results
        session[:results] = nil
    end

    def set_result(id, value)
        results_table[id.to_s] = value
    end

    def save_results
        session[:dbResult].update_attributes({
            :results => ActiveSupport::JSON::encode(results_table),
            :total => results_table.length, 
            :success => results_table.count{|c| c[1] }
        })
    end


    def replace_host(value)
        port = (request.port == 80) ? "" : (":" + request.port.to_s)
        value.gsub("{host}", request.host + port).gsub(
            "{other_host}", (request.host == APP_CONFIG["origin1"] ? APP_CONFIG["origin2"] : APP_CONFIG["origin1"]) + port
            ).gsub("{origin1}", APP_CONFIG["origin1"] + port).gsub("{origin2}", APP_CONFIG["origin2"] + port)
    end
end
