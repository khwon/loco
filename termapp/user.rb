#coding: utf-8
require_relative 'locoterm'
def draw_login(locoterm,failed: false)
  locoterm.clrtoeol(0..23)
  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.mvaddstr(2,8,'=$')
    locoterm.mvaddstr(3,3,'~OMMMMM8.')
    locoterm.mvaddstr(4,2,'MMMMMMMMM+')
    locoterm.mvaddstr(5,4,',MMMMMMN')
    locoterm.mvaddstr(6,5,'~MMMMMM')
    locoterm.mvaddstr(7,6,'NMMMMM')
    locoterm.mvaddstr(8,6,':MMMMM~')
    locoterm.mvaddstr(9,7,'MMMMM,')
    locoterm.mvaddstr(10,7,'IMMMM~')
    locoterm.mvaddstr(11,7,'=MMMM:')
    locoterm.mvaddstr(12,7,'.MMMM.')
    locoterm.mvaddstr(13,7,':MMMNID.')
    locoterm.mvaddstr(14,7,',MMMMMM$')
    locoterm.mvaddstr(15,7,'.MMMMZI$.')
    locoterm.mvaddstr(16,7,'=+.')
  end

  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.mvaddstr(5,26,',=,,')
    locoterm.mvaddstr(6,20,':OMMMMMMMMM?')
    locoterm.mvaddstr(7,18,'?MMMMMMMMMMMMM')
    locoterm.mvaddstr(8,16,'.OMMMMMMMMMMMMMM,')
    locoterm.mvaddstr(9,16,'NMMMMM$:  .   +M+')
    locoterm.mvaddstr(10,15,'.MMM8.        ?MM=')
    locoterm.mvaddstr(11,16,'MM:.     ,$MMMMM.')
    locoterm.mvaddstr(12,16,'DMMMMMMMMMMMMMMO')
    locoterm.mvaddstr(13,16,'.IMMMMMMMMMMMM?.')
    locoterm.mvaddstr(14,19,'+MMMMMMMMI.')
    locoterm.mvaddstr(15,22,'.  .')
  end

  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.mvaddstr(3,40,'=ZMMMMDI.')
    locoterm.mvaddstr(4,36,'?MMMD=   =MMMM')
    locoterm.mvaddstr(5,34,'IMMMM8  $MMMMMMMO')
    locoterm.mvaddstr(6,33,',MMMMM=  MMMMMMMM7')
    locoterm.mvaddstr(7,33,'$MMMMMZ .DMMMMM8=.')
    locoterm.mvaddstr(8,33,'OMMMMMM    .')
    locoterm.mvaddstr(9,33,'~MMMMMM:       O7')
    locoterm.mvaddstr(10,33,'.MMMMMMM7   .ZMM,')
    locoterm.mvaddstr(11,34,'?MMMMMMMMMMMMM.')
    locoterm.mvaddstr(12,36,'MMMMMMMMMM+.')
    locoterm.mvaddstr(13,38,',.~ ..')
  end

  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.mvaddstr(2,56,':ZMMMMMMMMM:')
    locoterm.mvaddstr(3,54,'?MMMMMMMMMMMMM')
    locoterm.mvaddstr(4,52,'.DMMMMMMMMMMMMMM')
    locoterm.mvaddstr(5,52,'MMMMMM$:    ..OM~')
    locoterm.mvaddstr(6,51,',MMMO         IMM,')
    locoterm.mvaddstr(7,51,'.MM..     .7MMMMM')
    locoterm.mvaddstr(8,52,'MMMMMMMMMMMMMMM7')
    locoterm.mvaddstr(9,52,'.OMMMMMMMMMMMM~')
    locoterm.mvaddstr(10,54,'.$MMMMMMMM7')
    locoterm.mvaddstr(11,61,'.')
  end

  locoterm.set_color(LocoTerm::COLOR_WHITE) do
    locoterm.mvaddstr(13,50,'managed by GoN security')
    locoterm.mvaddstr(14,52,'since 1999')
  end
  locoterm.mvaddstr(17,35,"type 'new' to join")
  locoterm.mvaddstr(18,35,"there is no guest ID")
  hor = "─"
  locoterm.mvaddstr(19,32,"┌"+hor*30+"┐")
  locoterm.mvaddstr(20,5,"total hit: 14520652")
  locoterm.mvaddstr(21,5,"today hit: 229")
  locoterm.mvaddstr(20,32,"│")
  locoterm.mvaddstr(20,63,"│")
  locoterm.mvaddstr(21,32,"│")
  locoterm.mvaddstr(21,63,"│")
  locoterm.mvaddstr(22,32,"│")
  locoterm.mvaddstr(22,63,"│")
  locoterm.mvaddstr(23,32,"└"+hor*30+"┘")

  locoterm.mvaddstr(20,35,"ID : ")
  locoterm.mvaddstr(21,35,"PW : ")
  locoterm.mvaddstr(22,35,"Login failed!") if failed
  locoterm.refresh
end

def get_login_cred(locoterm)
  id = ""
  pw = ""
  locoterm.mvgetnstr(20,40,id,20)
  locoterm.mvgetnstr(21,40,pw,20,echo: false)
  [id,pw]
end

def do_login(locoterm)
  user = nil
  tried = false
  while user.nil?
    draw_login(locoterm, failed: tried)
    tried = true
    id,pw = get_login_cred(locoterm)
    if id != "new"
      user = User.authorize(id,pw)
    end
  end
  locoterm.current_user = user
end
