# frozen_string_literal: true

require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"
rescue LoadError => exc

end
#
begin
  RSpec::Core::RakeTask.new(:spec)
rescue NameError, LoadError => exc

end
#
#
begin
  require "rubocop/rake_task"
rescue LoadError => exc

end
#
begin
  RuboCop::RakeTask.new
rescue NameError, LoadError => exc

end
#
begin
  task default: %i[spec rubocop]
rescue LoadError => exc

end



