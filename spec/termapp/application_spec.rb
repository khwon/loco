require 'rails_helper'
require 'application'

RSpec.describe TermApp::Application, type: :termapp do
  include TermAppHelper
  include LoginHelper

  describe '.run' do
    subject(:app) { silence_warnings { described_class.new([]) } }
    let!(:original_mvgetnstr) { app.term.method(:mvgetnstr) }

    it "processes GoodbyeMenu when get 'off' as id" do
      mock_id_input(app.term, 'off')
      # GoodbyeMenu
      allow(app.term).to receive(:get_wch) { [Ncurses::OK, 10, "\n"] }
      app.run

      expect(app.term).to have_received_id.once
      expect(app.term).to have_received(:get_wch).with(no_args).once

      cached_processors = app.instance_variable_get(:@cached_processors)
      expect(cached_processors).to only_have_processors(%i(
        login_menu
        goodbye_menu
      ))
    end

    context 'when logged in' do
      let(:user) { FactoryGirl.create(:user) }

      it 'processes WelcomeMenu and LocoMenu' do
        mock_id_input(app.term, user.username)
        mock_pw_input(app.term, user.password)
        allow(User).to receive(:find_by)
          .with(username: user.username).and_return(user)
        allow(user).to receive(:auth)
          .with(user.password).and_call_original
        allow(user).to receive(:admin?).and_call_original
        allow(app.term).to receive(:get_wch).and_return(
          # WelcomeMenu
          [Ncurses::OK, 10, "\n"],
          # g
          [Ncurses::OK, 103, 'g'],
          # LocoMenu
          [Ncurses::OK, 10, "\n"],
          # GoodbyeMenu
          [Ncurses::OK, 10, "\n"]
        )

        app.run

        expect(app.term).to have_received_id.once
        expect(app.term).to have_received_pw.once
        expect(User).to have_received(:find_by)
          .with(username: user.username).once
        expect(user).to have_received(:auth)
          .with(user.password).once
        expect(user).to have_received(:admin?).with(no_args).once
        expect(app.term).to have_received(:get_wch)
          .with(no_args).exactly(4).times

        cached_processors = app.instance_variable_get(:@cached_processors)
        expect(cached_processors).to only_have_processors(%i(
          login_menu
          welcome_menu
          loco_menu
          goodbye_menu
        ))
      end
    end
  end
end
