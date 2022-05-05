# frozen_string_literal: true

require 'concurrent-ruby'

module ApolloStudioTracing
  class ShutdownBarrier
    def initialize
      @latch = Concurrent::CountDownLatch.new(1)
    end

    def await_shutdown(timeout_secs)
      @latch.wait(timeout_secs)
    end

    def shutdown
      @latch.count_down
    end

    def shutting_down?
      @latch.count.zero?
    end
  end
end
