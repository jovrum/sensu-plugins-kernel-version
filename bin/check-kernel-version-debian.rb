#! /usr/bin/env ruby
# encoding: UTF-8

# check-kernel-version
#
# DESCRIPTION:
# Check Linux kernel version against the given target version on a Debian-based
# operating system.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#

require 'sensu-plugin/check/cli'
require 'open3'
require 'shellwords'

class CheckKernelVersion < Sensu::Plugin::Check::CLI
  option :target_version,
         short: '-t',
         long: '--target-version VERSION',
         description: 'Target kernel version',
         required: true

  def run
    current_kernel = `uname --kernel-release`.chomp
    stdout, stderr, status = Open3.capture3([
      'dpkg',
      '--compare-versions',
      current_kernel,
      'ge', # Greater than or equal to
      config[:target_version]].shelljoin)

    ok if status.success?
    warning(stderr) unless stderr.empty?
    warning("running older version #{current_kernel}")
  end
end
