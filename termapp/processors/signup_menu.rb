module TermApp
  class SignupMenu < Processor
    TEMPLATE = <<END.freeze
  LOCO BBS join
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
아이디를 새로 만듭니다. ('off'는 취소)

     아이디  :

   비밀번호  :
   비번확인  :

사용자이름(별명) :
     실  명  :
     성  별  :

     이메일  :


                                                    터미널 (vt100)
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
END
    def process
      term.erase_body
      draw_template
      print_message('사용할 아이디를 입력해 주세요.')
      id = get_id
      if id == 'off'
        return :goodbye_menu
      end
      print_message('비밀 번호를 잊어버리지 않도록 조심하세요.')
      pw = get_pw
      print_message('user 보기할 때 나오는 이름입니다.')
      nick = get_nick
      print_message('실명을 입력해주세요.')
      realname = get_realname
      print_message('성별을 입력해주세요.')
      sex = get_sex
      print_message('이메일 주소를 입력하여 주세요.')
      email = get_email
      term.mvaddstr(17, 1, '정말 가입하시겠습니까? (Y/N) [Y] ')
      key = KeyHelper.key_symbol(term.get_wch)
      if %i(n N).include? key
        return :goodbye_menu
      else
        u = User.create!(username: id, password: pw, nickname: nick,
                         realname: realname, sex: sex, email: email)
        term.current_user = u
        return :welcome_emnu
      end
    end

    private

    def get_id
      id = ''
      while id == ''
        term.move(6, 15)
        term.clrtoeol
        term.mvgetnstr(6, 15, id, 20)
        id = id.strip
        if id == 'off'
          return id
        elsif %w(new anonymous bbs admin administrator).include? id
          print_message('지원되지 않는 아이디입니다.')
          id = ''
        else
          if User.find_by(username: id)
            id = ''
            print_message('이미 다른 분이 사용중인 아이디입니다.')
          else
            id.codepoints.each do |x|
              if x < 128
                if (!(0x41..0x5a).cover?(x)) &&
                   (!(0x61..0x7a).cover?(x)) &&
                   (!(0x30..0x39).cover?(x))
                  id = ''
                  print_message('아이디는 한글, 숫자, 영문만 사용 가능합니다')
                end
              elsif x < 0xac00 || x > 0xd800
                id = ''
                print_message('아이디는 한글, 숫자, 영문만 사용 가능합니다')
              end
            end
          end
        end
      end
      id
    end

    def get_pw
      pw = ''
      pw_confirm = ''
      term.noecho
      while pw == ''
        term.mvgetnstr(8, 15, pw, 20)
        if pw == ''
          print_message('비밀번호를 입력하세요.')
          next
        end
        term.mvgetnstr(9, 15, pw_confirm, 20)
        if pw != pw_confirm
          print_message('비밀번호가 다릅니다.')
        end
      end
      term.echo
      pw
    end

    def get_nick
      get_str(11)
    end

    def get_realname
      get_str(12)
    end

    def get_sex
      str = ''
      while str == ''
        term.mvgetnstr(13, 15, str, 3)
        unless %w(M m F f 남 여).include? str
          str = ''
          print_message('(남/여) 혹은 (M/F)만 가능합니다.')
        end
      end
    end

    def get_email
      get_str(15, 20)
    end

    def get_str(yidx, maxsize = 10)
      str = ''
      term.mvgetnstr(yidx, 15, str, maxsize) while str == ''
    end

    def draw_template
      term.mvaddstr(2, 0, TEMPLATE)
    end

    def print_message(str)
      term.move(20, 0)
      term.clrtoeol
      term.mvaddstr(20, 0, '│')
      term.color_yellow do
        term.bold { term.mvaddstr(20, 3, str) }
      end
      term.mvaddstr(20, 67, '│')
    end
  end
end
