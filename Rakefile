require 'rake'
require 'rdoc/task'

task :default => :test

task :test do
  require 'simplecov'
  SimpleCov.start do
    add_filter "lib/tasks/"
    add_filter "test/"
  end
  require File.dirname(__FILE__)+'/lib/active_presenter'
  Dir.glob(File.dirname(__FILE__)+'/lib/tasks/**/*.rake').each { |l| load l }
  Dir['test/**/*_test.rb'].each { |l| require File.join(File.dirname(__FILE__),l)}
end
