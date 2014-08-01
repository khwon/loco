require 'rubocop/rake_task'
RuboCop::RakeTask.new do |rubocop|
  rubocop.formatters = %w(progress offenses)
end
task default: :rubocop
