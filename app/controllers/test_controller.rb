class TestController < ApplicationController

  def pass
    set_result(params[:id], true)
    head 200
  end

  def fail
    set_result(params[:id], false)
    head 403
  end

  def load
    @test = TestCase.get_testcase(params[:id])
    if (@test)
        set_result(@test.id, !@test.expect)
        
        response.headers["X-WebKit-CSP"] = replace_host(@test.header)
        response.headers["X-Content-Security-Policy"] = replace_host(@test.header)
        render :file => "app/views/testcase_templates/" + @test.template, :layout => false
    else 
        head 404
    end
  end

  def results
    @results = results_table
    respond_to do |format|
        format.json { render :json => @results }
    end
  end
end
