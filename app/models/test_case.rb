class TestCase

    attr_accessor :id, :expect, :title, :header, :template, :options

    @@testcases = {}
    @@testcase_id = 0

    def initialize(id, expect, title, header, template, options)
        @id = id
        @expect = expect
        @title = title
        @header = header
        @template = template
        @options = options
    end

    def uri (request)
        host = ""
        if (options[:include_host]) 
            host = (options[:protocol] || "http") + "://" + (request.port == 80 ? request.host : request.host_with_port)
        end
        host + (options[:redirect] ? "/redirect" : "/test") + (expect ? "/pass" : "/fail") + "/" + id.to_s + "?_=" + Time.new().to_f().to_s
    end

    def self.all
        self.checkload()
        @@testcases.values
    end

    def self.get_testcase(id)
        self.checkload()
        @@testcases[id.to_s]
    end

    def self.testcase(expect, title, header, template, options = {})
        @id = @@testcase_id
        @@testcase_id = @@testcase_id + 1
        @@testcases[@id.to_s] = TestCase.new(@id, expect, title, header, template, options)
    end

    def self.checkload() 
        @@testcases = @@testcases || {}
        if (@@testcases.length == 0)
            self.load()
        end
    end

    def self.load() 
        self.create_testcases("stylesheet", "style-src",  "linked_style.erb", "")
        self.testcase(true,  "Use inline styles",           "default-src 'self'; style-src 'self' 'unsafe-inline'", "inline_style.erb")
        self.testcase(false, "Use inline styles violation", "style-src 'self'",           "inline_style.erb")
        self.testcase(true,  "Use inline style attributes", "style-src 'self' 'unsafe-inline'", "inline_style_attr.erb")
        self.testcase(false, "Use inline style attributes violation", "style-src 'self'",           "inline_style_attr.erb")
        self.create_testcases("script",     "script-src", "linked_script.erb","")
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
        self.create_testcases("object",     "object-src", "object.erb",       "", {:tag => "object", :attr => "data", :extra => " type=\"application/x-shockwave-flash\""})
        self.create_testcases("embed",      "object-src", "object.erb",       "", {:tag => "embed", :attr => "src", :extra => " type=\"application/x-shockwave-flash\""})
        # not reliable self.create_testcases("applet",     "object-src", "object.erb",       "", {:tag => "applet", :attr => "codebase", :extra => " code=\"HelloWorld.class\""})
        self.create_testcases("frame",      "frame-src",  "iframe.erb",       "")
        self.create_testcases("font",       "font-src",   "font.erb",         ";style-src 'unsafe-inline")
        self.create_testcases("audio",      "media-src",  "media.erb",        "", {:tag => "audio"})
        self.create_testcases("video",      "media-src",  "media.erb",        "", {:tag => "video"})
        self.create_testcases("xhr",         "connect-src", "connect_xhr.erb",            ";script-src 'self' 'unsafe-inline'")
        self.create_testcases("EventSource", "connect-src", "connect_eventsource.erb",    ";script-src 'self' 'unsafe-inline'")
        self.create_testcase_list_standard("WebSockets",  "connect-src", "ws://{host}" , "connect_websockets.erb",     ";script-src 'self' 'unsafe-inline'", {:protocol => "ws", :include_host => true})
    end

    def self.create_testcases(type, directive, template, additional, options = {})
        self.create_testcase_list(type, directive, "'self'", template, additional, options)
        self.create_testcase_list(type, directive, "{host}", template, additional, options)
    end

    def self.create_testcase_list(type, directive, value, template, additional, options = {})
        self.create_testcase_list_standard(type, directive, value, template, additional, options)
        self.testcase(false, "Load " + type + " from " + directive + " with redirect from allowed to disallowed", directive + " {host}" + additional, template, {:redirect => true}.merge(options))
        self.testcase(true,  "Load " + type + " from " + directive + " with redirect from allowed to allowed", directive + " {origin1} {origin2}" + additional, template, {:redirect => true}.merge(options))

    end
    def self.create_testcase_list_standard(type, directive, value, template, additional, options = {})
        self.testcase(true,  "Load " + type + " from default-src " + value,           "default-src " + value + additional,                                template, options)
        self.testcase(false, "Load " + type + " from default-src 'none'",             "default-src 'none'" + additional,                                  template, options)
        self.testcase(true,  "Load " + type + " from " + directive + " " + value,     "default-src 'none'; " + directive + " " + value + additional,      template, options)
        self.testcase(false, "Load " + type + " from " + directive + " 'none'",       "default-src " + value + "; " + directive + " 'none'" + additional, template, options)
    end
end