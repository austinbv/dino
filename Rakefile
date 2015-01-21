require "bundler/gem_helper"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :gem do
  Bundler::GemHelper.install_tasks
end

desc 'release and bump up version'
task :release do
  ENV['GEM_PLATFORM'] = 'linux'
  Rake::Task['gem:release'].invoke

  require 'smalrubot/version'
  next_version = Smalrubot::VERSION.split('.').tap { |versions|
    versions[-1] = (versions[-1].to_i + 1).to_s
  }.join('.')
  File.open('lib/smalrubot/version.rb', 'r+') do |f|
    lines = []
    while line = f.gets
      line = "#{$1} '#{next_version}'\n" if /(\s*VERSION = )/.match(line)
      lines << line
    end
    f.rewind
    f.write(lines.join)
  end
  sh 'git add lib/smalrubot/version.rb'
  sh "git commit -m #{next_version}"
  sh 'git push'
end

task :default => [:spec]
