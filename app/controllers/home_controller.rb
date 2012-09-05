class HomeController < ApplicationController
    def index
        @testcase_json = replace_host(TestCase.all.sort{|x,y| x.id <=> y.id}.to_json)
    end

    def about

    end
end
