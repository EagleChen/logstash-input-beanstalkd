# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "beaneater"
require "json"

# This input will read jobs from a Beanstalk tube. It uses Beaneater(https://github.com/beanstalkd/beaneater)
# to interact with beanstalkd. The default input codec is json

class LogStash::Inputs::Beanstalkd < LogStash::Inputs::Base
  config_name "beanstalkd"

  # The address of the beanstalk server
  config :host, :validate => :string, :required => true

  # The port of your beanstalk server
  config :port, :validate => :number, :default => 11300

  # The name of the beanstalk tube
  config :tube, :validate => :string, :required => true

  # The priority of the job
  config :priority, :validate => :number, :default => 1024

  # The delay of the job in second
  config :delay, :validate => :number, :default => 0

  # The 'time to run' of the job
  config :ttr, :validate => :number, :default => 120

  # The reserve time of the job in second
  config :reserve, :validate => :number, :default => 5

  public
  def register
    Beaneater.configure do |config|
      config.default_put_delay   = @delay
      config.default_put_pri     = @priority
      config.default_put_ttr     = @ttr
    end
    @beanstalk = Beaneater.new("#{@host}:#{@port}")
    @beanstalk.tubes.watch!(@tube)
  end # def register

  def run(queue)
    while !stop?
      job = @beanstalk.tubes.reserve(@reserve)
      begin
        event = LogStash::Event.new(JSON.parse(job.body))
        decorate(event)
        queue << event
        job.delete
      rescue IOError, EOFError, LogStash::ShutdownSignal => e
        # stdin closed or a requested shutdown
        break
      rescue => e
        @logger.warn(["Trouble parsing beanstalk job",
                     {:error => e.message, :body => job.body,
                      :backtrace => e.backtrace}])
        job.bury
      end
    end # loop
  end # def run

  def stop
    @beanstalk.close
  end
end # class LogStash::Inputs::Beanstalkd
