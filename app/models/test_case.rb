class TestCase

    attr_accessor :id, :expect, :title, :header, :template, :options, :version, :load_uri

    @@testcases = {}
    @@testcase_id = 0

    def initialize(id, expect, title, header, template, options, version = 1.0)
        @id = id
        @expect = expect
        @title = title
        @header = header
        @template = template
        @options = options
        @version = version
        @load_uri = "/test/" + (options[:load_part] || "load") + "/" + id.to_s + "?" + (options[:query] || "")

    end

    def uri (request)
        host = ""
        if (options[:include_host]) 
            host = (options[:protocol] || "http") + "://" + request.host + port(request) 
        elsif (options[:include_other_host]) 
            host = (options[:protocol] || "http") + "://" + (request.host == APP_CONFIG["origin1"] ? APP_CONFIG["origin2"] : APP_CONFIG["origin1"]) + port(request) 
        elsif (options[:redirect])
            host = "http://" + (request.host == APP_CONFIG["origin1"] ? APP_CONFIG["origin2"] : APP_CONFIG["origin1"]) + port(request) 
        end
        host + (options[:redirect] ? "/redirect" : "/test") + (expect ? "/pass" : "/fail") + "/" + id.to_s + "?_=" + Time.new().to_f().to_s
    end

    def port(request)
        (request.port == 80 ? "" : (":" + request.port.to_s))
    end

    def self.version(version)
        self.all.find_all{ |t| t.version <= version }
    end

    def self.all
        self.checkload()
        @@testcases.values
    end

    def self.get_testcase(id)
        self.checkload()
        @@testcases[id.to_s]
    end

    def self.testcase(expect, title, header, template, options = {}, version = 1.0)
        @id = @@testcase_id
        @@testcase_id = @@testcase_id + 1
        @@testcases[@id.to_s] = TestCase.new(@id, expect, title, header, template, options, version)
    end

    def self.checkload() 
        @@testcases = @@testcases || {}
        if (@@testcases.length == 0)
            self.load()
        end
    end

    def self.load() 
        self.load_1_0()
        self.load_1_1_draft()
    end
    def self.load_1_0()
        self.create_testcases("stylesheet", "style-src",  "linked_style.erb", "")
        self.testcase(false, "Style set to 'self' + base",   "style-src 'self'",   "linked_style.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.testcase(true,  "Style in data-uri allowed",    "default-src 'self'; style-src data: ",  "linked_style_data.erb", { :include_host => true })
        self.testcase(false, "Style in data-uri disallowed", "default-src 'self'; style-src 'self'",  "linked_style_data.erb", { :include_host => true })
        self.testcase(true,  "Use inline styles",           "default-src 'self'; style-src 'self' 'unsafe-inline'", "inline_style.erb")
        self.testcase(false, "Use inline styles violation", "style-src 'self'",           "inline_style.erb")
        self.testcase(true,  "Use inline style attributes", "style-src 'self' 'unsafe-inline'", "inline_style_attr.erb")
        self.testcase(false, "Use inline style attributes violation", "style-src 'self'",           "inline_style_attr.erb")
        self.create_testcases("script",     "script-src", "linked_script.erb","")
        self.testcase(false, "Script set to 'self' + base",   "script-src 'self'", "linked_script.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.testcase(true,  "Script in data-uri allowed",    "default-src 'self'; script-src data: ",  "linked_script_data.erb", { :include_host => true })
        self.testcase(false, "Script in data-uri disallowed", "default-src 'self'; script-src 'self'",  "linked_script_data.erb", { :include_host => true })
        self.testcase(true,  "Use inline script",           "script-src 'unsafe-inline'", "inline_script_tag.erb")
        self.testcase(false, "Use inline script violation", "script-src 'self'",          "inline_script_tag.erb")
        self.testcase(true,  "Use inline script in event handler",           "script-src 'unsafe-inline'",  "inline_script_eventhandler.erb")
        self.testcase(false, "Use inline script in event handler violation", "script-src 'self'",           "inline_script_eventhandler.erb")
        self.testcase(true,  "Use eval in script", "script-src 'unsafe-eval' 'unsafe-inline'",  "eval_script.erb")
        self.testcase(false, "Use eval in script violation", "script-src 'unsafe-inline'",      "eval_script.erb")
        self.testcase(true,  "Use eval in script Function", "script-src 'unsafe-eval' 'unsafe-inline'",  "eval_script_function.erb")
        self.testcase(false, "Use eval in script Function violation", "script-src 'unsafe-inline'",      "eval_script_function.erb")
        self.testcase(true,  "Use eval in script setTimeout", "script-src 'unsafe-eval' 'unsafe-inline'",  "eval_script_settimeout.erb")
        self.testcase(false, "Use eval in script setTimeout violation", "script-src 'unsafe-inline'",      "eval_script_settimeout.erb")
        self.testcase(true,  "Use script setTimeout function", "script-src 'unsafe-inline'",  "script_settimeout_function.erb")
        self.testcase(true,  "Use eval in script setInterval", "script-src 'unsafe-eval' 'unsafe-inline'",  "eval_script_setinterval.erb")
        self.testcase(false, "Use eval in script setInterval violation", "script-src 'unsafe-inline'",      "eval_script_setinterval.erb")
        self.testcase(true,  "Use script setInterval function", "script-src 'unsafe-inline'",  "script_setinterval_function.erb")
        self.create_testcases("image",      "img-src",    "img.erb",          "")
        self.testcase(false, "Img set to 'self' + base",   "img-src 'self'", "img.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.testcase(true,  "Style wants image, and allowed by img-src",    "default-src 'self'; img-src 'self'; style-src 'unsafe-inline'", "inline_style.erb")
        self.testcase(false, "Style wants image, but disallowed by img-src", "default-src 'self'; img-src 'none'; style-src 'unsafe-inline'", "inline_style.erb")
        self.testcase(true,  "Img in data-uri allowed",    "default-src 'self'; img-src data: ; script-src 'unsafe-inline'",  "img_data.erb")
        self.testcase(false, "Img in data-uri disallowed", "default-src 'self'; img-src 'self'; script-src 'unsafe-inline'",  "img_data.erb")
        self.create_testcases("object",     "object-src", "object.erb",       "", {:tag => "object", :attr => "data", :extra => " type=\"application/x-shockwave-flash\""})
        self.testcase(false, "object set to 'self' + base",   "object-src 'self'", "object.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true, :tag => "object", :attr => "data", :extra => " type=\"application/x-shockwave-flash\""  })
        self.create_testcases("embed",      "object-src", "object.erb",       "", {:tag => "embed", :attr => "src", :extra => " type=\"application/x-shockwave-flash\""})
        self.testcase(false, "embed set to 'self' + base",   "object-src 'self'", "object.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true, :tag => "embed", :attr => "src", :extra => " type=\"application/x-shockwave-flash\""  })
        # not reliable self.create_testcases("applet",     "object-src", "object.erb",       "", {:tag => "applet", :attr => "codebase", :extra => " code=\"HelloWorld.class\""})
        self.create_testcases("frame",      "frame-src",  "iframe.erb",       "")
        self.testcase(false, "Iframe set to 'self' + base",   "frame-src 'self'", "iframe.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.testcase(true,  "Iframe with data-uri allowed",    "default-src 'self'; frame-src data: ",  "iframe_data.erb", { :include_host => true })
        self.testcase(false, "Iframe with data-uri disallowed", "default-src 'self'; frame-src 'self'",  "iframe_data.erb", { :include_host => true })
        self.create_testcases("font",       "font-src",   "font.erb",         ";style-src 'unsafe-inline'")
        self.testcase(false, "Font set to 'self' + base",   "font-src 'self'; style-src 'unsafe-inline'", "font.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.create_testcases("audio",      "media-src",  "media.erb",        "", {:tag => "audio"})
        self.testcase(false, "Audio set to 'self' + base",   "media-src 'self'", "media.erb", { :tag => "audio", :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.create_testcases("video",      "media-src",  "media.erb",        "", {:tag => "video"})
        self.testcase(false, "Video set to 'self' + base",   "media-src 'self'", "media.erb", { :tag => "video", :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.create_testcases("xhr",         "connect-src", "connect_xhr.erb",            ";script-src 'self' 'unsafe-inline'")
        self.create_testcase_list_standard("EventSource", "connect-src", "'self'", "connect_eventsource.erb",    ";script-src 'self' 'unsafe-inline'")
        self.create_testcase_list_standard("EventSource", "connect-src", "{host}", "connect_eventsource.erb",    ";script-src 'self' 'unsafe-inline'")
        self.create_testcase_list_standard("WebSockets",  "connect-src", "ws://{host}" , "connect_websockets.erb",     ";script-src 'self' 'unsafe-inline'", {:protocol => "ws", :include_host => true})

        self.testcase(true,  "SVG - scripting", "script-src 'unsafe-inline'", "svg_script.erb", {})
        self.testcase(false, "SVG - scripting", "script-src 'self'",          "svg_script.erb", {})
        self.testcase(true,  "SVG - scripting event handler", "script-src 'unsafe-inline'", "svg_script_attr.erb", {})
        self.testcase(false, "SVG - scripting event handler", "script-src 'self'",          "svg_script_attr.erb", {})
        self.testcase(true,  "SVG - scripting foreign object", "script-src 'unsafe-inline'", "svg_script_foreign_object.erb", {})
        self.testcase(false, "SVG - scripting foreign object", "script-src 'self'",          "svg_script_foreign_object.erb", {})

        self.testcase(true,  "SVG - object in foreign object", "default-src 'self'; style-src 'unsafe-inline'", "svg_foreign_object.erb", {})
        self.testcase(false, "SVG - object in foreign object", "default-src 'self'; style-src 'unsafe-inline'; object-src 'none'", "svg_foreign_object.erb", {})

        self.testcase(true,  "SVG - img in foreign object", "default-src 'self'; style-src 'unsafe-inline'", "svg_img.erb", {})
        self.testcase(false, "SVG - img in foreign object", "default-src 'self'; style-src 'unsafe-inline'; img-src 'none'", "svg_img.erb", {})

        self.testcase(true,  "SVG - video in foreign object", "default-src 'self'; style-src 'unsafe-inline'", "svg_media.erb", {:tag => "video"})
        self.testcase(false, "SVG - video in foreign object", "default-src 'self'; style-src 'unsafe-inline'; media-src 'none'", "svg_media.erb", {:tag => "video"})
        self.testcase(true,  "SVG - audio in foreign object", "default-src 'self'; style-src 'unsafe-inline'", "svg_media.erb", {:tag => "audio"})
        self.testcase(false, "SVG - audio in foreign object", "default-src 'self'; style-src 'unsafe-inline'; media-src 'none'", "svg_media.erb", {:tag => "audio"})

        self.testcase(false, "Sandbox", "sandbox", "sandbox_inner.erb", {:allow_same_origin => true, :allow_scripts => true, :container_template => "sandbox_container.erb", :load_part => "container"}, 1.0)
        self.testcase(true,  "Sandbox", "sandbox allow-scripts", "sandbox_inner.erb", {:allow_same_origin => false, :allow_scripts => true, :container_template => "sandbox_container.erb", :load_part => "container"}, 1.0)
        self.testcase(false, "Sandbox", "sandbox allow-scripts", "sandbox_inner.erb", {:allow_same_origin => true, :allow_scripts => false, :container_template => "sandbox_container.erb", :load_part => "container"}, 1.0)
        self.testcase(true,  "Sandbox", "sandbox allow-same-origin allow-scripts", "sandbox_inner.erb", {:allow_same_origin => true, :allow_scripts => false, :container_template => "sandbox_container.erb", :load_part => "container"}, 1.0)


    end

    def self.load_1_1_draft() 
        self.testcase(true,  "Form-action 'self'",       "form-action 'self'; script-src 'unsafe-inline'",       "form_action.erb", {}, 1.1)
        self.testcase(true,  "Form-action {host}",       "form-action {host}; script-src 'unsafe-inline'",       "form_action.erb", {}, 1.1)
        self.testcase(false, "Form-action 'none'",       "form-action 'none'; script-src 'unsafe-inline'",       "form_action.erb", {}, 1.1)
        self.testcase(true,  "Form-action {other_host}", "form-action {other_host}; script-src 'unsafe-inline'", "form_action.erb", { :include_other_host => true }, 1.1)
        self.testcase(false, "Form-action {other_host} but post to self", "form-action {other_host}; script-src 'unsafe-inline'", "form_action.erb", {}, 1.1)
        self.testcase(false, "Form-action with redirect from allowed to disallowed", "form-action {other_host}; script-src 'unsafe-inline'",     "form_action.erb", {:redirect => true}, 1.1)
        self.testcase(true,  "Form-action with redirect from allowed to allowed", "form-action {origin1} {origin2}; script-src 'unsafe-inline'", "form_action.erb", {:redirect => true}, 1.1)

        self.testcase(true,  "Script-nonce correct",    "script-src 'nonce-correctnonce' ",    "script_nonce.erb", {:nonce_attribute => "nonce=\"correctnonce\""},     1.1)

        self.testcase(false, "Script-nonce wrong",      "; script-src 'nonce-somenonce' ",       "script_nonce.erb", {:nonce_attribute => "nonce=\"wrongnonce\""},       1.1)
        self.testcase(false, "Script-nonce missing",    "; script-src 'nonce-somenonce' ",       "script_nonce.erb", {:nonce_attribute => ""},       1.1)
        self.testcase(false, "Script-nonce set and javascript in event handler",    "; script-src 'nonce-somenonce' ",  "script_nonce_eventhandler.erb", {},  1.1)

        self.testcase(false, "Script-nonce empty in header",                   "script-src 'nonce-' ",      "script_nonce.erb", {:nonce_attribute => ""},       1.1)
        self.testcase(false, "Script-nonce empty in header but not on tag",    "script-src 'nonce-' ",      "script_nonce.erb", {:nonce_attribute => "nonce=\"somenonce\""},       1.1)
        self.testcase(false, "Script-nonce set and javascript in event handler",    "script-src 'nonce-' ", "script_nonce_eventhandler.erb", {},  1.1)

        self.testcase(true,  "Plugin-types embed allowed",    "default-src 'self'; plugin-types application/x-shockwave-flash", "object.erb", {:tag => "embed", :attr => "src", :extra => " type=\"application/x-shockwave-flash\""}, 1.1)
        self.testcase(false, "Plugin-types embed disallowed", "default-src 'self'; plugin-types application/x-shockwave-flash", "object.erb", {:tag => "embed", :attr => "src", :extra => " type=\"application/pdf\""}, 1.1)
        self.testcase(true,  "Plugin-types object allowed",    "default-src 'self'; plugin-types application/x-shockwave-flash", "object.erb", {:tag => "object", :attr => "data", :extra => " type=\"application/x-shockwave-flash\""}, 1.1)
        self.testcase(false, "Plugin-types object disallowed", "default-src 'self'; plugin-types application/x-shockwave-flash", "object.erb", {:tag => "object", :attr => "data", :extra => " type=\"application/pdf\""}, 1.1)
        self.testcase(true,   "Plugin-types bare - not set",    "default-src 'self'", "",   {:load_part => "flash", :query => "pass=true"}, 1.1)        
        self.testcase(true,   "Plugin-types bare - allowed",    "default-src 'self'; plugin-types application/x-shockwave-flash", "",   {:load_part => "flash", :query => "pass=true"}, 1.1)        
        self.testcase(false,  "Plugin-types bare - disallowed", "default-src 'self'; plugin-types application/x-shockwave-flash", "", {:load_part => "flash", :query => "pass=false"}, 1.1)        

        self.create_testcases("child",      "child-src",  "iframe.erb",       "")
        self.testcase(false, "Iframe set to 'self' + base",   "child-src 'self'", "iframe.erb", { :head_content => '<base href="{other_host}" />', :include_other_host => true  })
        self.testcase(true,  "Iframe with data-uri allowed",    "default-src 'self'; child-src data: ",  "iframe_data.erb", { :include_host => true })
        self.testcase(false, "Iframe with data-uri disallowed", "default-src 'self'; child-src 'self'",  "iframe_data.erb", { :include_host => true })

    end

    def self.create_testcases(type, directive, template, additional, options = {}, version = 1.0)
        self.create_testcase_list(type, directive, "'self'", template, additional, options, version)
        self.create_testcase_list(type, directive, "{host}", template, additional, options, version)
    end

    def self.create_testcase_list(type, directive, value, template, additional, options = {}, version = 1.0)
        self.create_testcase_list_standard(type, directive, value, template, additional, options, version)
        self.testcase(false, "Load " + type + " from " + directive + " with redirect from allowed to disallowed", directive + " {other_host}" + additional, template, {:redirect => true}.merge(options), version)
        self.testcase(true,  "Load " + type + " from " + directive + " with redirect from allowed to allowed", directive + " {origin1} {origin2}" + additional, template, {:redirect => true}.merge(options), version)

    end
    def self.create_testcase_list_standard(type, directive, value, template, additional, options = {}, version = 1.0)
        self.testcase(true,  "Load " + type + " from default-src " + value,           "default-src " + value + additional,                                template, options, version)
        self.testcase(false, "Load " + type + " from default-src 'none'",             "default-src 'none'" + additional,                                  template, options, version)
        self.testcase(true,  "Load " + type + " from " + directive + " " + value,     "default-src 'none'; " + directive + " " + value + additional,      template, options, version)
        self.testcase(false, "Load " + type + " from " + directive + " 'none'",       "default-src " + value + "; " + directive + " 'none'" + additional, template, options, version)
    end
end
