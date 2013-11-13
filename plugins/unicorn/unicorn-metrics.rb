#!/usr/bin/env ruby
#
#
# Copyright 2013 Invoca Inc.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'net/https'
require 'uri'
require 'socket'

class UnicornMetrics < Sensu::Plugin::Metric::CLI::Graphite

  option :hostname,
    :short => "-h HOSTNAME",
    :long => "--host HOSTNAME",
    :description => "Nginx hostname",
    :default => "127.0.0.1"

  option :port,
    :short => "-P PORT",
    :long => "--port PORT",
    :description => "Nginx  port",
    :default => "80"

  option :path,
    :short => "-q STATUSPATH",
    :long => "--statspath STATUSPATH",
    :description => "Path to your stub status module",
    :default => "/_raindrops"

  option :scheme,
    :description => "Metric naming scheme, text to prepend to metric",
    :short => "-s SCHEME",
    :long => "--scheme SCHEME",
    :default => "#{Socket.gethostname}.unicorn"

  def run
    response = Net::HTTP.get(config[:hostname], config[:path])
    active, queued = response.split("\n")[2..3].map { |line| line.split(":").last.to_i }
    output "#{config[:scheme]}.active", active
    output "#{config[:scheme]}.queued", queued
    ok
  end

end
