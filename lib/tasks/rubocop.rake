require 'rubocop/rake_task'
RuboCop::RakeTask.new do |rubocop|
  rubocop.formatters = %w(simple offenses)
end
