class TestCase

    attr_accessor :id, :expect, :title, :header, :template

    @@testcases = {}
    @@testcase_id = 0

    def initialize(id, expect, title, header, template)
        @id = id
        @expect = expect
        @title = title
        @header = header
        @template = template
    end

    def uri
        "/test/" + (expect ? "pass" : "fail") + "/" + id.to_s + "?_=" + Time.new().to_f().to_s 
    end

    def self.all
        self.checkload()
        @@testcases.values
    end

    def self.get_testcase(id)
        self.checkload()
        @@testcases[id.to_s]
    end

    def self.testcase(expect, title, header, template)
        @id = @@testcase_id
        @@testcase_id = @@testcase_id + 1
        @@testcases[@id.to_s] = TestCase.new(@id, expect, title, header, template)
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
        self.create_testcases("object",     "object-src", "object.erb",       "")
        self.create_testcases("frame",      "frame-src",  "iframe.erb",       "")
        self.create_testcases("font",       "font-src",   "font.erb",         ";style-src 'unsafe-inline")
        self.create_testcases("audio",      "media-src",  "audio.erb",        "")
        self.create_testcases("video",      "media-src",  "video.erb",        "")
        self.create_testcases("xhr",        "connect-src","connect_xhr.erb",  ";script-src 'self' 'unsafe-inline'")
    end

    def self.create_testcases(type, directive, template, additional)
        self.create_testcase_list(type, directive, "'self'", additional, template)
        self.create_testcase_list(type, directive, "{host}", additional, template)
    end

    def self.create_testcase_list(type, directive, value, additional, template)
        self.testcase(true,  "Load " + type + " from default-src " + value,           "default-src " + value + additional,                                template)
        self.testcase(false, "Load " + type + " from default-src 'none'",             "default-src 'none'" + additional,                                  template)
        self.testcase(true,  "Load " + type + " from " + directive + " " + value,     "default-src 'none'; " + directive + " " + value + additional,      template)
        self.testcase(false, "Load " + type + " from " + directive + " 'none'",       "default-src " + value + "; " + directive + " 'none'" + additional, template)
    end
end