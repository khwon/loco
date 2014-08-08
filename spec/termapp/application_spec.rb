require 'rails_helper'
require_relative '../../config/environment'
require 'application'

module LoginHelpers
  def mock_id_input(dummy_id)
    mocking = true
    allow(subject.term).to receive(:mvgetnstr).with(
                             20, 40, anything, 20) do |y, x, str, n|
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
    allow(subject.term).to receive(:mvgetnstr).with(
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
end

RSpec.describe TermApp::Application, type: :termapp do
  include TermAppHelpers
  include LoginHelpers

  describe '.run' do
    subject { silence_warnings { TermApp::Application.new } }
    let!(:original_mvgetnstr) { subject.term.method(:mvgetnstr) }

    it "processes GoodbyeMenu when get 'off' as id" do
      mock_id_input('off')
      # GoodbyeMenu
      allow(subject.term).to receive(:getch) { Ncurses::KEY_ENTER }
      subject.run

      expect(subject.term).to have_received_id.once
      expect(subject.term).to have_received(:getch).with(no_args).once

      cached_processors = subject.instance_variable_get(:@cached_processors)
      expect(cached_processors).to only_have_processors(
                                     %i(
                                       login_menu
                                       goodbye_menu
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
        allow(subject.term).to receive(:getch).and_return(
                                 # WelcomeMenu
                                 Ncurses::KEY_ENTER,
                                 # g
                                 103,
                                 # LocoMenu
                                 Ncurses::KEY_ENTER,
                                 # GoodbyeMenu
                                 Ncurses::KEY_ENTER
                               )

        subject.run

        expect(subject.term).to have_received_id.once
        expect(subject.term).to have_received_pw.once
        expect(User).to have_received(:find_by).with(username: user.username)
                                               .once
        expect(user).to have_received(:try).with(:authenticate, user.password)
                                           .once
        expect(user).to have_received(:admin?).with(no_args).once
        expect(subject.term).to have_received(:getch).with(no_args)
                                                     .exactly(4).times

        cached_processors = subject.instance_variable_get(:@cached_processors)
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
