group :specs, halt_on_fail: true do
  # Note: The cmd option is now required due to the increasing number of ways
  #       rspec may be run, below are examples of the most common uses.
  #  * bundler: 'bundle exec rspec'
  #  * bundler binstubs: 'bin/rspec'
  #  * spring: 'bin/rsspec' (This will use spring if running and you have
  #                          installed the spring binstubs per the docs)
  #  * zeus: 'zeus rspec' (requires the server to be started separetly)
  #  * 'just' rspec: 'rspec'
  guard :rspec, cmd: 'bin/rspec' do
    watch(/^spec\/.+_spec\.rb$/)
    watch(/^lib\/(.+)\.rb$/)     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(/^termapp\/(.+)\.rb$/) { |m| "spec/termapp/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { 'spec' }

    # Rails example
    watch('spec/rails_helper.rb') { 'spec' }
    watch(%r{^spec/support/(.+)\.rb$}) { 'spec' }
    watch('config/routes.rb') { 'spec/routing' }
    watch(/^app\/(.+)\.rb$/) { |m| "spec/#{m[1]}_spec.rb" }
    watch(/^app\/(.*)(\.erb|\.haml|\.slim)$/) do |m|
      "spec/#{m[1]}#{m[2]}_spec.rb"
    end
    watch('app/controllers/application_controller.rb') { 'spec/controllers' }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  do |m|
      ["spec/routing/#{m[1]}_routing_spec.rb",
       "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
       "spec/acceptance/#{m[1]}_spec.rb"]
    end

    # Capybara features specs
    # watch(%r{^app/views/(.+)/.*\.(erb|haml|slim)$}) do |m|
    #   "spec/features/#{m[1]}_spec.rb"
    # end

    # Turnip features and steps
    # watch(%r{^spec/acceptance/(.+)\.feature$})
    # watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) do |m|
    #   Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance'
    # end
  end

  guard :rubocop, all_on_start: false do
    watch(/.+\.rb$/)
    watch(/(?:.+\/)?\.rubocop\.yml$/) { |m| File.dirname(m[0]) }
    watch(/(?:.+\/)?Gemfile$/)
    watch(/(?:.+\/)?Guardfile$/)
    watch(/(?:.+\/)?Rakefile$/)
    watch(/(?:.+\/)?config\.ru$/)
    watch(/.+\.rake$/)
  end
end
