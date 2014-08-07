$LOAD_PATH.unshift(File.expand_path('../../../termapp', __FILE__))

RSpec::Matchers.define :only_have_processors do |expected|
  match do |actual|
    expected.size == actual.size && contain_all?(expected, actual)
  end

  def contain_all?(expected, actual)
    expected.all? { |e| actual[e].is_a? e.to_s.classify.constantize }
  end
end
