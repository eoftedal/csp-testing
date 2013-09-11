class TestController < ApplicationController

  def pass
    set_result(params[:id], true)
    response.headers["Access-Control-Allow-Origin"] = "http://" + swap
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["X-Access-Control-Allow-Origin"] = "http://" + swap
    response.headers["X-Access-Control-Allow-Credentials"] = "true"
   head 200
  end

  def fail
    set_result(params[:id], false)
    response.headers["Access-Control-Allow-Origin"] = "http://" + swap
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["X-Access-Control-Allow-Origin"] = "http://" + swap
    response.headers["X-Access-Control-Allow-Credentials"] = "true"
    head 403
  end

  def swap
    host = request.host == APP_CONFIG["origin1"] ? APP_CONFIG["origin2"] : APP_CONFIG["origin1"]
    port = request.port == 80 ? "" : (":" + request.port.to_s)
    host + port
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


  def load_container
    @test = TestCase.get_testcase(params[:id])
    if (@test)
        render :file => "app/views/testcase_templates/" + @test.options[:container_template], :layout => false
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
