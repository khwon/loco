$LOAD_PATH.unshift(File.expand_path('../../../termapp', __FILE__))

# Custom matchers for TermApp test.
module TermAppHelper
  extend RSpec::Matchers::DSL

  matcher :only_have_processors do |expected|
    match do |actual|
      expected.size == actual.size && contain_all?(expected, actual)
    end

    def contain_all?(expected, actual)
      expected.all? do |e|
        actual[e].is_a? "TermApp::#{e.to_s.classify}".constantize
      end
    end
  end

  matcher :have_received_id do
    match do |actual|
      result = have_received(:mvgetnstr).with(20, 40, anything, 20)
      @count_args.each do |args|
        result.send(*args)
      end
      expect(actual).to result
    end

    %i(exactly at_least at_most times once twice).each do |expectation|
      chain expectation do |*args|
        @count_args ||= []
        @count_args << [expectation, *args]
      end
    end
  end

  matcher :have_received_pw do
    match do |actual|
      result = have_received(:mvgetnstr).with(21, 40, anything, 20, echo: false)
      @count_args.each do |args|
        result.send(*args)
      end
      expect(actual).to result
    end

    %i(exactly at_least at_most times once twice).each do |expectation|
      chain expectation do |*args|
        @count_args ||= []
        @count_args << [expectation, *args]
      end
    end
  end
end
