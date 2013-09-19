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
         :short => '-w ACTIVE, QUEUED',
         :long => '--warn ACTIVE, QUEUED',
         :proc => proc {|a| a.split(',').map {|t| (t == 'n' || t == 'N') ? 'n' : t.to_i } },
         :default => [10,'n']

  option :crit,
         :short => '-c ACTIVE, QUEUED',
         :long => '--crit ACTIVE, QUEUED',
         :proc => proc {|a| a.split(',').map {|t| (t == 'n' || t == 'N') ? 'n' : t.to_i } },
         :default => ['n',0 ]

  def run
    response = Net::HTTP.get('127.0.0.1', '/_raindrops')
    active, queued = response.split("\n")[2..3].map { |line| line.split(":").last.to_i }
    message "Active #{active}, Queued #{queued}"
    (config[:crit][0] == 'n') || (critical if active > config[:crit][0])
    (config[:crit][1] == 'n') || (critical if queued > config[:crit][1])
    (config[:warn][0] == 'n') || (warning if active > config[:warn][0])
    (config[:warn][1] == 'n') || (warning if queued > config[:warn][1])
    ok
  end
end
