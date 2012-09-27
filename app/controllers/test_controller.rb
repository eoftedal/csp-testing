class TestController < ApplicationController

  def pass
    set_result(params[:id], true)
    head 200
  end

  def fail
    set_result(params[:id], false)
    head 403
  end

  def flash
    @test = TestCase.get_testcase(params[:id])
    if (@test)
        set_result(@test.id, !@test.expect)
        if (!session[:disable_old_headers])
          response.headers["X-WebKit-CSP"] = replace_host(@test.header)
          response.headers["X-Content-Security-Policy"] = replace_host(@test.header)
        end 
        response.headers["Content-Security-Policy"] = replace_host(@test.header)
        send_file 'public/csp.swf', :type => "application/x-shockwave-flash", :disposition => 'inline' 
    else 
        head 404
    end
  end

  def load
    @test = TestCase.get_testcase(params[:id])
    if (@test)
        set_result(@test.id, !@test.expect)
        if (!session[:disable_old_headers])
          response.headers["X-WebKit-CSP"] = replace_host(@test.header)
          response.headers["X-Content-Security-Policy"] = replace_host(@test.header)
        end 
        response.headers["Content-Security-Policy"] = replace_host(@test.header)
        render :file => "app/views/testcase_templates/" + @test.template, :layout => false
    else 
        head 404
    end
  end

  def results
    @results = results_table
    save_results
    respond_to do |format|
        format.json { render :json => @results }
    end
  end
end
