# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/beanstalkd"
require "beaneater"

describe LogStash::Inputs::Beanstalkd do
  let (:valid_config) {{'host' => 'localhost', 'tube' => 'test'}}
  let (:empty_config) {{}}
  let (:non_default_config) {{'host' => 'localhost', 'tube' => 'test', 'priority' => 20, 'delay' => 10, 'ttr' => 10}}
  let (:conf) {
    <<-CONFIG
      input {
        beanstalkd {
          host => "localhost"
          tube => "test"
        }
      }
    CONFIG
  }

  it "parse config" do
    expect do
      LogStash::Plugin.lookup("input", "beanstalkd").new(valid_config)
    end.to_not raise_error
  end

  it "fails with empty config" do
    expect do
      LogStash::Plugin.lookup("input", "beanstalkd").new(valid_config)
    end.to_not raise_error
  end

  it "can parse beanstalkd related data" do
    expect do
      LogStash::Plugin.lookup("input", "beanstalkd").new(valid_config)
    end.to_not raise_error
  end

  # this test requires a running beanstalkd on localhost:11300
  it "receive jobs" do
    job = '{"test": 1}'
    beanstalk = Beaneater.new('localhost:11300')
    tube = beanstalk.tubes["test"]
    tube.put job
    beanstalk.close

    result = input(conf) do |pipeline, queue|
      queue.size.times.collect { queue.pop }
    end

    expect(result.size).to eq(1)
    expect(result[0]["test"]).to eq(1)
  end

end
