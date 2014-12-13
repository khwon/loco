require 'rubocop/rake_task'
RuboCop::RakeTask.new do |rubocop|
  rubocop.formatters = %w(progress offenses)
  rubocop.options = %w(--display-cop-names)
end
task default: :rubocop
