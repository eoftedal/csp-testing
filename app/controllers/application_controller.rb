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
        host = request.port == 80 ? request.host : request.host_with_port
        value.gsub("{host}", host)
    end

end
