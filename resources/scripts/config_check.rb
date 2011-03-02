#!/usr/bin/env ruby

require "fileutils"

Config =
  {
    :banner => "# Rails Environment Configuration.\n",
    :git_config_incomplete => "\nYour git configuration is incomplete.\nuser.name and user.email are required for properly using git and services such \nas GitHub ( http://github.com/ ).\n",
    :git_name_prompt => " name > ",
    :git_email_prompt => " email > ",
    :railsinstaller_path => File.dirname(File.dirname($0)),
    :home       => File.join( ENV["HOMEDRIVE"], ENV["HOMEPATH"] ),
    :ssh_path   => File.join( ENV["HOMEDRIVE"], ENV["HOMEPATH"], ".ssh" ),
    :ssh_key    => File.join( ENV["HOMEDRIVE"], ENV["HOMEPATH"], ".ssh", "id_rsa"),
    :ssh_keygen => File.join( File.dirname(File.dirname($0)), "Git", "bin", "ssh-keygen.exe"),
    :git        => File.join( File.dirname(File.dirname($0)), "Git", "bin", "git.exe")
  }

#
# Methods
#
def run(command)
  $stderr.puts "Running #{command}" if Config[:debug]
  %x{#{command}}.chomp
end

def generate_ssh_key
  run %Q{#{Config[:ssh_keygen]} -f "#{Config[:ssh_key]}" -t rsa -b 2048 -N "" -C "#{git_config("user.name")} <#{git_config("user.email")}>"}
end

def git_config(key)
  run %Q{#{Config[:git]} config --global #{key}}
end

#
# Configuration
#
printf Config[:banner]

["name","email"].each do |key|
  while git_config("user.#{key}").empty?
    if Config[:git_config_incomplete]
      printf Config[:git_config_incomplete]
			Config[:git_config_incomplete] = nil
		end
    printf Config["git_#{key}_prompt".to_sym]
    value = gets.chomp
    next if value.empty?
    printf "Setting user.#{key} to #{value}"
    run %Q{#{Config[:git]} config --global user.#{key} "#{value}"}
  end
end

FileUtils.mkdir_p(Config[:ssh_path]) unless File.exist? Config[:ssh_path]
generate_ssh_key                     unless File.exist? Config[:ssh_key]

#
# Emit Summary
#
printf "---
git:
  user.name:  #{git_config("user.name")}
  user.email: #{git_config("user.email")}
  version:    #{run "git --version"}
ssh:
  public_key: #{Config[:ssh_key]}
ruby:
  bin:        #{File.join(Config[:railsinstaller_path], "Ruby1.8.7", "bin", "ruby.exe")}
  version:    #{run "ruby -v"}
rails:
  bin:        #{File.join(Config[:railsinstaller_path], "Ruby1.8.7", "bin", "rails.bat")}
  version:    #{run "rails -v"}

"

exit 0
