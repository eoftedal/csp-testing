class HomeController < ApplicationController
    def index
        new_results
        session[:version] = 1.0
        if (params[:disable_old_headers]) 
            session[:disable_old_headers] = params[:disable_old_headers] == "true"
        end
        @testcase_json = replace_host(TestCase.version(1.0).sort{|x,y| x.id <=> y.id}.to_json)
        @other_host = replace_host("{other_host}")
        @session_id = request.session_options[:id]
    end

    def draft_1_1
        new_results
        session[:version] = 1.1
        if (params[:disable_old_headers]) 
            session[:disable_old_headers] = params[:disable_old_headers] == "true"
        end
        @testcase_json = replace_host(TestCase.version(1.1).sort{|x,y| x.id <=> y.id}.to_json)
        @other_host = replace_host("{other_host}")
        @session_id = request.session_options[:id]
        render :index
    end

    def establish
        response.headers["Set-Cookie"] =  "_session_id=" + params[:session_id].to_s + ";path=/;httponly"
        render :establish, :layout => false
    end

    def results
        # @results = Result.find(:all, :order => "id desc", :limit => 100)
        @results = Result.where("total IS NOT NULL").order("id desc").limit(100);
    end

    def about

    end
end
