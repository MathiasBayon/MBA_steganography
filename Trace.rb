require 'logger'

$LOG_FILENAME = "logfile.log"

class Trace

    def self.get_logger
        @@logger ||= Logger.new($LOG_FILENAME, 10, 1024000)
    end
    
end