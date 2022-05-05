# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'uri'
require 'zlib'

module ApolloStudioTracing
  module API
    extend self

    APOLLO_URL = 'https://engine-report.apollodata.com/api/ingress/traces'
    APOLLO_URI = ::URI.parse(APOLLO_URL)
    UploadAttemptError = Class.new(StandardError)
    RetryableUploadAttemptError = Class.new(UploadAttemptError)

    def upload(report_data, max_attempts:, min_retry_delay_secs:, **options)
      attempt ||= 0
      attempt_upload(report_data, **options)
    rescue UploadAttemptError => e
      attempt += 1
      if e.is_a?(RetryableUploadAttemptError) && attempt < max_attempts
        retry_delay = min_retry_delay_secs * 2**attempt
        ApolloStudioTracing.logger.warn(
          "Attempt to send trace report failed and will be retried in #{retry_delay} " \
          "secs: #{e.message}",
        )
        sleep(retry_delay)
        retry
      else
        ApolloStudioTracing.logger.warn("Failed to send trace report: #{e.message}")
      end
    end

    private

    def attempt_upload(report_data, compress:, api_key:)
      body = compress ? gzip(report_data) : report_data
      headers = { 'X-Api-Key' => api_key }
      headers['Content-Encoding'] = 'gzip' if compress
      result = Net::HTTP.post(APOLLO_URI, body, headers)

      if result.is_a?(Net::HTTPServerError)
        raise RetryableUploadAttemptError, "#{result.code} #{result.message} - #{result.body}"
      end

      if !result.is_a?(Net::HTTPSuccess)
        raise UploadAttemptError, "#{result.message} (#{result.code}) - #{result.body}"
      end
    rescue IOError, SocketError, SystemCallError, OpenSSL::OpenSSLError => e
      raise RetryableUploadAttemptError, "#{e.class} - #{e.message}"
    end

    def gzip(data)
      output = StringIO.new
      output.set_encoding('BINARY')
      gz = Zlib::GzipWriter.new(output)
      gz.write(data)
      gz.close
      output.string
    end
  end
end
