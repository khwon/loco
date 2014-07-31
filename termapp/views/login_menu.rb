class LoginMenu < TermApp::View
  def process
    user = nil
    tried = false
    id = ''
    pw = ''
    until user
      draw_login(failed: tried)
      tried = true
      term.mvgetnstr(20, 40, id, 20)
      return :goodbye_menu if id == 'off'
      term.mvgetnstr(21, 40, pw, 20, echo: false)
      next if id == 'new'
      user = User.find_by(username: id).try(:authenticate, pw)
    end
    term.current_user = user
    :welcome_menu
  end

  private

  def draw_login(failed: false)
    term.clrtoeol(0..23)
    term.set_color(TermApp::Terminal.colors.sample) do
      term.mvaddstr(2, 8, '=$')
      term.mvaddstr(3, 3, '~OMMMMM8.')
      term.mvaddstr(4, 2, 'MMMMMMMMM+')
      term.mvaddstr(5, 4, ',MMMMMMN')
      term.mvaddstr(6, 5, '~MMMMMM')
      term.mvaddstr(7, 6, 'NMMMMM')
      term.mvaddstr(8, 6, ':MMMMM~')
      term.mvaddstr(9, 7, 'MMMMM,')
      term.mvaddstr(10, 7, 'IMMMM~')
      term.mvaddstr(11, 7, '=MMMM:')
      term.mvaddstr(12, 7, '.MMMM.')
      term.mvaddstr(13, 7, ':MMMNID.')
      term.mvaddstr(14, 7, ',MMMMMM$')
      term.mvaddstr(15, 7, '.MMMMZI$.')
      term.mvaddstr(16, 7, '=+.')
    end

    term.set_color(TermApp::Terminal.colors.sample) do
      term.mvaddstr(5, 26, ',=,,')
      term.mvaddstr(6, 20, ':OMMMMMMMMM?')
      term.mvaddstr(7, 18, '?MMMMMMMMMMMMM')
      term.mvaddstr(8, 16, '.OMMMMMMMMMMMMMM,')
      term.mvaddstr(9, 16, 'NMMMMM$:  .   +M+')
      term.mvaddstr(10, 15, '.MMM8.        ?MM=')
      term.mvaddstr(11, 16, 'MM:.     ,$MMMMM.')
      term.mvaddstr(12, 16, 'DMMMMMMMMMMMMMMO')
      term.mvaddstr(13, 16, '.IMMMMMMMMMMMM?.')
      term.mvaddstr(14, 19, '+MMMMMMMMI.')
      term.mvaddstr(15, 22, '.  .')
    end

    term.set_color(TermApp::Terminal.colors.sample) do
      term.mvaddstr(3, 40, '=ZMMMMDI.')
      term.mvaddstr(4, 36, '?MMMD=   =MMMM')
      term.mvaddstr(5, 34, 'IMMMM8  $MMMMMMMO')
      term.mvaddstr(6, 33, ',MMMMM=  MMMMMMMM7')
      term.mvaddstr(7, 33, '$MMMMMZ .DMMMMM8=.')
      term.mvaddstr(8, 33, 'OMMMMMM    .')
      term.mvaddstr(9, 33, '~MMMMMM:       O7')
      term.mvaddstr(10, 33, '.MMMMMMM7   .ZMM,')
      term.mvaddstr(11, 34, '?MMMMMMMMMMMMM.')
      term.mvaddstr(12, 36, 'MMMMMMMMMM+.')
      term.mvaddstr(13, 38, ',.~ ..')
    end

    term.set_color(TermApp::Terminal.colors.sample) do
      term.mvaddstr(2, 56, ':ZMMMMMMMMM:')
      term.mvaddstr(3, 54, '?MMMMMMMMMMMMM')
      term.mvaddstr(4, 52, '.DMMMMMMMMMMMMMM')
      term.mvaddstr(5, 52, 'MMMMMM$:    ..OM~')
      term.mvaddstr(6, 51, ',MMMO         IMM,')
      term.mvaddstr(7, 51, '.MM..     .7MMMMM')
      term.mvaddstr(8, 52, 'MMMMMMMMMMMMMMM7')
      term.mvaddstr(9, 52, '.OMMMMMMMMMMMM~')
      term.mvaddstr(10, 54, '.$MMMMMMMM7')
      term.mvaddstr(11, 61, '.')
    end

    term.set_color(TermApp::Terminal::COLOR_WHITE) do
      term.mvaddstr(13, 50, 'managed by GoN security')
      term.mvaddstr(14, 52, 'since 1999')
    end
    term.mvaddstr(17, 35, "type 'new' to join")
    term.mvaddstr(18, 35, 'there is no guest ID')
    hor = '─'
    term.mvaddstr(19, 32, '┌' + hor * 30 + '┐')
    term.mvaddstr(20, 5, 'total hit: 14520652')
    term.mvaddstr(21, 5, 'today hit: 229')
    term.mvaddstr(20, 32, '│')
    term.mvaddstr(20, 63, '│')
    term.mvaddstr(21, 32, '│')
    term.mvaddstr(21, 63, '│')
    term.mvaddstr(22, 32, '│')
    term.mvaddstr(22, 63, '│')
    term.mvaddstr(23, 32, '└' + hor * 30 + '┘')

    term.mvaddstr(20, 35, 'ID : ')
    term.mvaddstr(21, 35, 'PW : ')
    term.mvaddstr(22, 35, 'Login failed!') if failed
    term.refresh
  end
end
