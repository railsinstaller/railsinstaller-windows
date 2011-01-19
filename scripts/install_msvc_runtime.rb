#!/usr/bin/env ruby

packages_path = ARGV[1]

tmp_path = ARGV[2]

file = "vcredist_x86.exe"

FileUtils.cp(
  File.join(packages_path,file),
  File.join(tmp_path,file)
)

exec "#{File.join(tmp_path, file)} /q"

