
module ActionDispatch
  module Session
    class MemoryStore < ActionDispatch::Session::AbstractStore
      GLOBAL_HASH_TABLE = {} #:nodoc:

      private
        def get_session(env, sid)
          sid ||= generate_sid
          session = GLOBAL_HASH_TABLE[sid] || {}
          session = Rack::Session::Abstract::SessionHash.new(self, env).merge(session)
          [sid, session]
        end

        def set_session(env, sid, session_data, cookie_settings)
          GLOBAL_HASH_TABLE[sid] = session_data
          return true
        end
    end
  end
end