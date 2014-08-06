require 'rails_helper'
require_relative '../../config/environment'
require 'application'
require 'processor'
Dir[File.expand_path('../../../termapp/processors/*.rb', __FILE__)]
  .each { |f| require f }

RSpec.describe TermApp, type: :termapp do
  context 'when it runs' do
    def mock_id_input(dummy_id)
      mocking = true
      allow(@app.term).to receive(:mvgetnstr).with(
        20, 40, anything, 20
      ) do |y, x, str, n|
        if mocking
          mocking = false
          str.replace(dummy_id)
        else
          original_mvgetnstr.call(y, x, str, n)
        end
      end
    end

    before(:example) do
      silence_warnings { @app = TermApp::Application.new }
    end
    let!(:original_mvgetnstr) { @app.term.method(:mvgetnstr) }

    it "processes GoodbyeMenu when get 'off' as id" do
      mock_id_input('off')
      # GoodbyeMenu
      allow(@app.term).to receive(:getch) { Ncurses::KEY_ENTER }
      @app.run

      cached_processors = @app.instance_variable_get(:@cached_processors)
      expect(cached_processors).to only_have_processors(%i(
        login_menu goodbye_menu
      ))
    end
  end
end
