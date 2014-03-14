#!/usr/bin/env ruby
#
# Check exhaustion of unicorn processes
# ===
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'net/http'

class CheckUnicornExhaustion < Sensu::Plugin::Metric::CLI::Graphite

  option :scheme,
         :description => "Metric naming scheme, text to prepend to metric",
         :short => "-s SCHEME",
         :long => "--scheme SCHEME",
         :default => "#{Socket.gethostname}.unicorn"

  def run
    response = Net::HTTP.get('127.0.0.1', '/_raindrops')
    calling, writing, active, queued = response.split("\n").map { |line| line.split(":").last.to_i }

    output "#{config[:scheme]}.unicorn.calling", calling
    output "#{config[:scheme]}.unicorn.writing", writing
    output "#{config[:scheme]}.unicorn.active", active
    output "#{config[:scheme]}.unicorn.queued", queued
    ok
  end
end
