# Helper methods for login process test of TermApp::Application.
module LoginHelpers
  def mock_id_input(term, dummy_id)
    mocking = true
    allow(term).to receive(:mvgetnstr).with(
                     20, 40, anything, 20) do |y, x, str, n|
      if mocking
        mocking = false
        str.replace(dummy_id)
      else
        original_mvgetnstr.call(y, x, str, n)
      end
    end
  end

  def mock_pw_input(term, dummy_pw)
    mocking = true
    allow(term).to receive(:mvgetnstr)
      .with(21, 40, anything, 20, echo: false) do |y, x, str, n, echo: false|
      if mocking
        mocking = false
        str.replace(dummy_pw)
      else
        original_mvgetnstr.call(y, x, str, n, echo: echo)
      end
    end
  end
end
