require 'rails_helper'
require_relative '../../config/environment'
require 'application'

RSpec.describe TermApp, type: :termapp do
  describe '.run' do
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

    def mock_pw_input(dummy_pw)
      mocking = true
      allow(@app.term).to receive(:mvgetnstr).with(
        21, 40, anything, 20, echo: false
      ) do |y, x, str, n, echo: false|
        if mocking
          mocking = false
          str.replace(dummy_pw)
        else
          original_mvgetnstr.call(y, x, str, n, echo: echo)
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

      expect(@app.term).to have_received_id.once
      expect(@app.term).to have_received(:getch).with(no_args).once

      cached_processors = @app.instance_variable_get(:@cached_processors)
      expect(cached_processors).to only_have_processors(%i(
        login_menu goodbye_menu
      ))
    end

    context 'when logged in' do
      let(:user) { FactoryGirl.create(:user) }

      it 'processes WelcomeMenu and LocoMenu' do
        mock_id_input('johndoe')
        mock_pw_input('password')
        allow(User).to receive(:find_by).with(username: user.username)
                                        .and_return(user)
        allow(user).to receive(:try).with(:authenticate, user.password)
                                    .and_call_original
        allow(user).to receive(:admin?).and_call_original
        allow(@app.term).to receive(:getch).and_return(
          # WelcomeMenu
          Ncurses::KEY_ENTER,
          # g
          103,
          # LocoMenu
          Ncurses::KEY_ENTER,
          # GoodbyeMenu
          Ncurses::KEY_ENTER
        )

        @app.run

        expect(@app.term).to have_received_id.once
        expect(@app.term).to have_received_pw.once
        expect(User).to have_received(:find_by).with(username: user.username)
                                               .once
        expect(user).to have_received(:try).with(:authenticate, user.password)
                                           .once
        expect(user).to have_received(:admin?).with(no_args).once
        expect(@app.term).to have_received(:getch).with(no_args)
                                                  .exactly(4).times

        cached_processors = @app.instance_variable_get(:@cached_processors)
        expect(cached_processors).to only_have_processors(%i(
          login_menu welcome_menu loco_menu goodbye_menu
        ))
      end
    end
  end
end
