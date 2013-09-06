#!/usr/bin/env ruby
#
# Check exhaustion of unicorn processes
# ===
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'net/http'

class CheckUnicornExhaustion < Sensu::Plugin::Check::CLI

  option :warn,
         :short => '-w ACTIVE',
         :long => '--warn ACTIVE',
         :proc => proc {|a| a.to_i },
         :default => 10

  option :crit,
         :short => '-c QUEUED',
         :long => '--crit QUEUED',
         :proc => proc {|a| a.to_i },
         :default => 0

  def run
    response = Net::HTTP.get('127.0.0.1', '/_raindrops')
    active, queued = response.split("\n")[2..3].map { |line| line.split(":").last.to_i }
    message "Active #{active}, Queued #{queued}"
    critical if queued > config[:crit]
    warning if active > config[:warn]
    ok
  end
end
