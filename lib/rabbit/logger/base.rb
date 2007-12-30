require "rabbit/gettext"

module Rabbit
  module Logger

    module Severity
      include GetText
      extend GetText

      DEBUG = 0
      INFO = 1
      WARNING = 2
      ERROR = 3
      FATAL = 4
      UNKNOWN = 5

      module_function
      def name(level)
        {
          DEBUG => _("DEBUG"),
          INFO => _("INFO"),
          WARNING => _("WARNING"),
          ERROR => _("ERROR"),
          FATAL => _("FATAL"),
          UNKNOWN => _("UNKNOWN"),
        }[level]
      end
    end

    module Base
      include Severity
      include GetText

      attr_accessor :level, :webrick_mode
      def initialize(level=INFO, prog_name=nil)
        @level = level
        @prog_name = prog_name
        @webrick_mode = false
      end
      
      def debug?; @level <= DEBUG; end
      def info?; @level <= INFO; end
      def warning?; @level <= WARNING; end
      def error?; @level <= ERROR; end
      def fatal?; @level <= FATAL; end
      def unknown?; @level <= UNKNOWN; end
    
      def debug(message_or_error=nil, &block)
        log(DEBUG, message_or_error, &block)
      end
      
      def info(message_or_error=nil, &block)
        log(INFO, message_or_error, &block)
      end
      
      def warning(message_or_error=nil, &block)
        log(WARNING, message_or_error, &block)
      end
      alias_method(:warn, :warning) # for backward compatibility

      def error(message_or_error=nil, &block)
        log(ERROR, message_or_error, &block)
      end

      def fatal(message_or_error=nil, &block)
        log(FATAL, message_or_error, &block)
      end
      
      def unknown(message_or_error=nil, &block)
        log(UNKNOWN, message_or_error, &block)
      end

      def <<(message_or_error)
        info(message_or_error)
      end
      
      def log(severity, message_or_error, prog_name=nil, &block)
        severity ||= UNKNOWN
        prog_name ||= @prog_name
        if need_log?(severity)
          if message_or_error.nil? and block_given?
            message_or_error = yield
          end
          if message_or_error
            do_log(severity, prog_name, make_message(message_or_error))
          end
        end
      end
      alias add log

      private
      def format_severity(severity)
        "[#{Severity.name(severity)}]"
      end

      def format_datetime(datetime)
        datetime.strftime("%Y-%m-%dT%H:%M:%S.") << "%06d " % datetime.usec
      end

      def make_message(message_or_error)
        if message_or_error.is_a?(Exception)
          "#{message_or_error.class}: #{message_or_error.message}\n" +
            %Q[#{message_or_error.backtrace.join("\n")}]
        else
          message_or_error
        end
      end

      def need_log?(severity)
        if @webrick_mode
          severity <= WEBrick::Log::DEBUG - @level
        else
          severity >= @level
        end
      end
    end
  end
end
