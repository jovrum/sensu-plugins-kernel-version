#! /usr/bin/env ruby
# encoding: UTF-8

# check-kernel-version
#
# DESCRIPTION:
# Check Linux kernel version against the given target version on a RedHat-based
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

  RPMDEV_VERCMP_EQ = 0
  RPMDEV_VERCMP_GT = 11
  RPMDEV_VERCMP_LT = 12

  def run
    current_kernel = `uname --kernel-release`.chomp
    stdout, stderr, status = Open3.capture3([
      'rpmdev-vercmp',
      current_kernel,
      config[:target_version]].shelljoin)

    warning("running older version #{current_kernel}") if status.exitstatus == RPMDEV_VERCMP_LT
    ok if [RPMDEV_VERCMP_EQ, RPMDEV_VERCMP_GT].include? status.exitstatus
    warning(stderr)
  end
end
