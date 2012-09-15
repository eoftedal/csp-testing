class HomeController < ApplicationController
    def index
        if (params[:disable_old_headers]) 
            session[:disable_old_headers] = params[:disable_old_headers] == "true"
        end
        @testcase_json = replace_host(TestCase.all.sort{|x,y| x.id <=> y.id}.to_json)
    end

    def results
        # @results = Result.find(:all, :order => "id desc", :limit => 100)
        @results = Result.where("total IS NOT NULL").order("id desc").limit(100);
    end

    def about

    end
end
