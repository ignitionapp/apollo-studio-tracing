# frozen_string_literal: true

module ApolloStudioTracing
  class ApolloLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "[#{timestamp}] #{severity} #{progname}: [Apollo Studio Tracing] #{msg}\n"
    end
  end
end
