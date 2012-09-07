class RedirectController < ApplicationController
  def pass
    response.headers["X-Access-Control-Allow-Origin"] = "http://" + swap
    response.headers["X-Access-Control-Allow-Credentials"] = "true"
    redirect_to url("pass")
  end

  def fail
    response.headers["X-Access-Control-Allow-Origin"] = "http://" + swap
    response.headers["X-Access-Control-Allow-Credentials"] = "true"
    redirect_to url("fail")
  end

  def url(expect)
    "http://" + swap +  "/test/" + expect + "/" + params[:id] + "?_=" + Time.new().to_f().to_s
  end

  def swap
    host = request.host == APP_CONFIG["origin1"] ? APP_CONFIG["origin2"] : APP_CONFIG["origin1"]
    port = request.port == 80 ? "" : (":" + request.port.to_s)
    host + port
  end

end
