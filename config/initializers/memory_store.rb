
module ActionDispatch
  module Session
    class MemoryStore < ActionDispatch::Session::AbstractStore
      GLOBAL_HASH_TABLE = {} #:nodoc:

      private
        def get_session(env, sid)
          sid ||= SecureRandom.hex(16)
          session = GLOBAL_HASH_TABLE[sid] || { :created => Time.now() }
          if (session[:created] == nil || session[:created] < (Time.now() - 30*60)) 
            session = { :created => Time.now() }
          end
          session = Rack::Session::Abstract::SessionHash.new(self, env).merge(session)
          [sid, session]
        end

        def set_session(env, sid, session_data, cookie_settings)
          GLOBAL_HASH_TABLE[sid] = session_data
          return sid
        end
    end
  end
end