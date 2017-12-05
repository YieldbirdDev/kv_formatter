# frozen_string_literal: true

class Logger
  class KeyValueFormatter
    attr_writer :base_proc

    def initialize(&block)
      @base_proc = block
    end

    # This method is called automatically by Logger
    def call(severity, time, _progname, message)
      "#{build_log_entry(severity, message, time)}\n"
    end

    # Modify #base_proc by #base_proc= setter or during initialization by passing a block:
    #   Logger::KeyValueFormatter.new do |_severity, _message, time|
    #     { additional: "fields", timestamp: time }
    #   end
    #
    # Every time new message is logged with Hash parameter, eg.
    #   logger.info(message: "something happened")
    #
    # passed parameters will be merged to result of #base_proc call, so, for above example, complete message will be:
    #   additional="fields" timestamp="2017-12-05T13:11:18+01:00" message="something happened"
    #
    # Default value of #base_proc would create message:
    #   source="APP" at="info" timestamp="2017-12-05T13:11:18+01:00" message="something happened"
    def base_proc
      @base_proc ||= proc do |severity, _message, time|
        { source: "APP", at: severity, timestamp: time }
      end
    end

    private

    def build_log_entry(severity, message, time)
      case message
      when String
        message
      when Hash
        data = base_proc.call(severity, message, time).merge! message
        build_key_value_pairs data
      else
        message.inspect
      end
    end

    def build_key_value_pairs(data)
      data.map do |k, v|
        case v
        when Hash
          # Allow single-level hash nesting to provide context namespacing
          # eg. foo: { bar: "baz" } would output foo-bar="baz"
          # where foo is the context of bar parameter
          v.map { |sk, sv| "#{k}-#{sk}=#{format_value(sv)}" }
        else
          "#{k}=#{format_value(v)}"
        end
      end.join(" ")
    end

    def format_value(val)
      case val
      when String   then val.inspect
      when Hash     then val.to_json
      when Float    then format("%.3f", val)
      when Time     then val.iso8601.inspect
      when NilClass then "nil"
      else val.to_s
      end
    end
  end
end
