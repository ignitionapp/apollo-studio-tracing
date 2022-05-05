# frozen_string_literal: true

require_relative 'api'
require_relative 'proto'
require_relative 'shutdown_barrier'

module ApolloStudioTracing
  # rubocop:disable Metrics/ClassLength
  class TraceChannel
    attr_reader :compress,
                :api_key,
                :reporting_interval,
                :max_uncompressed_report_size,
                :debug_reports,
                :max_upload_attempts,
                :min_upload_retry_delay_secs,
                :max_queue_bytes

    alias debug_reports? debug_reports

    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def initialize(report_header:, compress: nil, api_key: nil, reporting_interval: nil,
                   max_uncompressed_report_size: nil, max_queue_bytes: nil, debug_reports: nil,
                   max_upload_attempts: nil, min_upload_retry_delay_secs: nil)
      @report_header = report_header
      @compress = compress.nil? ? true : compress
      @api_key = api_key || ENV.fetch('ENGINE_API_KEY', ENV.fetch('APOLLO_KEY', 'NO_API_KEY'))
      @reporting_interval = reporting_interval || 5
      @max_uncompressed_report_size = max_uncompressed_report_size || 4 * 1024 * 1024
      @max_queue_bytes = max_queue_bytes || @max_uncompressed_report_size * 10
      @max_upload_attempts = max_upload_attempts || 5
      @min_upload_retry_delay_secs = min_upload_retry_delay_secs || 0.1
      @debug_reports = debug_reports.nil? ? false : debug_reports
      @queue = Queue.new
      @queue_bytes = Concurrent::AtomicFixnum.new(0)
      @queue_full = false
      @enqueue_mutex = Mutex.new
      @shutdown_barrier = ApolloStudioTracing::ShutdownBarrier.new
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    def queue(query_key, trace, context)
      @enqueue_mutex.synchronize do
        if @queue_bytes.value >= max_queue_bytes
          unless @queue_full
            ApolloStudioTracing.logger.warn(
              "Apollo tracing queue is above the threshold of #{max_queue_bytes} bytes and " \
              'trace collection will be paused.',
            )
            @queue_full = true
          end
        else
          if @queue_full
            ApolloStudioTracing.logger.info(
              "Apollo tracing queue is below the threshold of #{max_queue_bytes} bytes and " \
              'trace collection will resume.',
            )
            @queue_full = false
          end

          if debug_reports?
            ApolloStudioTracing.logger.info("Queueing a trace for #{query_key}")
          end

          proto = ApolloStudioTracing::Trace.new(
            start_time: to_proto_timestamp(trace[:start_time]),
            end_time: to_proto_timestamp(trace[:end_time]),
            duration_ns: trace[:end_time_nanos] - trace[:start_time_nanos],
            root: trace[:node_map].root,
            client_name: context[:apollo_client_name],
            client_version: context[:apollo_client_version],
          )

          encoded_trace = ApolloStudioTracing::Trace.encode(proto)
          @queue << [query_key, encoded_trace]
          @queue_bytes.increment(encoded_trace.bytesize + query_key.bytesize)

          ensure_thread_started
        end
      end
    end

    def start
      @uploader_thread = Thread.new do
        run_uploader
      end
    end

    def ensure_thread_started
      return if @uploader_thread&.alive?

      start
    end

    def flush
      until @queue.empty?
        # If the uploader thread isn't running then the queue will never drain
        break unless @uploader_thread&.alive?

        sleep(0.1)
      end
    end

    def shutdown
      return unless @uploader_thread

      ApolloStudioTracing.logger.info('Shutting down Apollo trace channel...')
      @shutdown_barrier.shutdown
      @uploader_thread.join
    end

    private

    def queue_full?
      @queue_bytes.value >= max_queue_bytes
    end

    def run_uploader
      ApolloStudioTracing.logger.info('Trace uploader starting')
      drain_queue until @shutdown_barrier.await_shutdown(reporting_interval)
      ApolloStudioTracing.logger.info('Draining queue before shutdown...')
      drain_queue
    rescue StandardError => e
      ApolloStudioTracing.logger.warn("Exception thrown in uploader process. #{e}")
      raise e
    ensure
      ApolloStudioTracing.logger.info('Trace uploader exiting')
    end

    def drain_queue
      traces_per_query = {}
      report_size = 0
      until @queue.empty?
        query_key, encoded_trace = @queue.pop(false)
        @queue_bytes.decrement(encoded_trace.bytesize + query_key.bytesize)

        traces_per_query[query_key] ||= []
        traces_per_query[query_key] << encoded_trace
        report_size += encoded_trace.bytesize + query_key.bytesize

        next unless report_size >= max_uncompressed_report_size

        send_report(traces_per_query)
        traces_per_query = {}
        report_size = 0
      end

      send_report(traces_per_query) unless traces_per_query.empty?
    end

    def send_report(traces_per_query)
      trace_report = ApolloStudioTracing::Report.new(header: @report_header)
      traces_per_query.each do |query_key, encoded_traces|
        trace_report.traces_per_query[query_key] = ApolloStudioTracing::TracesAndStats.new(
          # TODO: Figure out how to use the already encoded traces like Apollo
          # https://github.com/apollographql/apollo-server/blob/master/packages/apollo-engine-reporting-protobuf/src/index.js
          trace: encoded_traces.map do |encoded_trace|
            ApolloStudioTracing::Trace.decode(encoded_trace)
          end,
        )
      end

      if debug_reports?
        ApolloStudioTracing.logger.info(
          "Sending trace report:\n#{JSON.pretty_generate(JSON.parse(trace_report.to_json))}",
        )
      end

      ApolloStudioTracing::API.upload(
        ApolloStudioTracing::Report.encode(trace_report),
        api_key: api_key,
        compress: compress,
        max_attempts: max_upload_attempts,
        min_retry_delay_secs: min_upload_retry_delay_secs,
      )
    end

    def to_proto_timestamp(time)
      Google::Protobuf::Timestamp.new(seconds: time.to_i, nanos: time.nsec)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
