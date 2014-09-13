require 'rails_helper'
require_relative '../../config/environment'
require 'application'

RSpec.describe TermApp::Application, type: :termapp do
  include TermAppHelper
  include LoginHelper

  describe '.run' do
    subject(:app) { silence_warnings { TermApp::Application.new } }
    let!(:original_mvgetnstr) { app.term.method(:mvgetnstr) }

    it "processes GoodbyeMenu when get 'off' as id" do
      mock_id_input(app.term, 'off')
      # GoodbyeMenu
      allow(app.term).to receive(:getch) { Ncurses::KEY_ENTER }
      app.run

      expect(app.term).to have_received_id.once
      expect(app.term).to have_received(:getch).with(no_args).once

      cached_processors = app.instance_variable_get(:@cached_processors)
      expect(cached_processors).to only_have_processors(
                                     %i(
                                       login_menu
                                       goodbye_menu
                                     ))
    end

    context 'when logged in' do
      let(:user) { FactoryGirl.create(:user) }

      it 'processes WelcomeMenu and LocoMenu' do
        mock_id_input(app.term, 'johndoe')
        mock_pw_input(app.term, 'password')
        allow(User).to receive(:find_by).with(username: user.username)
                                        .and_return(user)
        allow(user).to receive(:try).with(:authenticate, user.password)
                                    .and_call_original
        allow(user).to receive(:admin?).and_call_original
        allow(app.term).to receive(:getch).and_return(
                             # WelcomeMenu
                             Ncurses::KEY_ENTER,
                             # g
                             103,
                             # LocoMenu
                             Ncurses::KEY_ENTER,
                             # GoodbyeMenu
                             Ncurses::KEY_ENTER
                           )

        app.run

        expect(app.term).to have_received_id.once
        expect(app.term).to have_received_pw.once
        expect(User).to have_received(:find_by).with(username: user.username)
                                               .once
        expect(user).to have_received(:try).with(:authenticate, user.password)
                                           .once
        expect(user).to have_received(:admin?).with(no_args).once
        expect(app.term).to have_received(:getch).with(no_args)
                                                 .exactly(4).times

        cached_processors = app.instance_variable_get(:@cached_processors)
        expect(cached_processors).to only_have_processors(
                                       %i(
                                         login_menu
                                         welcome_menu
                                         loco_menu
                                         goodbye_menu
                                       ))
      end
    end
  end
end
