require_relative 'locoterm'
require_relative 'goodbye'
def draw_login(locoterm, failed: false)
  locoterm.clrtoeol(0..23)
  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.print_block(2, 2, <<EOF
      =$
 ~OMMMMM8.
MMMMMMMMM+
  ,MMMMMMN
   ~MMMMMM
    NMMMMM
    :MMMMM~
     MMMMM,
     IMMMM~
     =MMMM:
     .MMMM.
     :MMMNID.
     ,MMMMMM$
     .MMMMZI$.
     =+.
EOF
    )
  end

  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.print_block(5, 15, <<EOF
           ,=,,
     :OMMMMMMMMM?
   ?MMMMMMMMMMMMM
 .OMMMMMMMMMMMMMM,
 NMMMMM$:  .   +M+
.MMM8.        ?MM=
 MM:.     ,$MMMMM.
 DMMMMMMMMMMMMMMO
 .IMMMMMMMMMMMM?.
    +MMMMMMMMI.
       .  .
EOF
    )
  end

  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.print_block(3, 33, <<EOF
       =ZMMMMDI.
   ?MMMD=   =MMMM
 IMMMM8  $MMMMMMMO
,MMMMM=  MMMMMMMM7
$MMMMMZ .DMMMMM8=.
OMMMMMM    .
~MMMMMM:       O7
.MMMMMMM7   .ZMM,
 ?MMMMMMMMMMMMM.
   MMMMMMMMMM+.
     ,.~ ..
EOF
    )
  end

  locoterm.set_color(LocoTerm.colors.sample) do
    locoterm.print_block(2, 51, <<EOF
     :ZMMMMMMMMM:
   ?MMMMMMMMMMMMM
 .DMMMMMMMMMMMMMM
 MMMMMM$:    ..OM~
,MMMO         IMM,
.MM..     .7MMMMM
 MMMMMMMMMMMMMMM7
 .OMMMMMMMMMMMM~
   .$MMMMMMMM7
          .
EOF
    )
  end

  locoterm.set_color(LocoTerm::COLOR_WHITE) do
    locoterm.mvaddstr(13, 50, 'managed by GoN security')
    locoterm.mvaddstr(14, 52, 'since 1999')
  end
  locoterm.mvaddstr(20, 5, 'total hit: 14520652')
  locoterm.mvaddstr(21, 5, 'today hit: 229')
  locoterm.print_block(17, 32, <<EOF
   type 'new' to join
   there is no guest ID
┌──────────────────────────────┐
│  ID :                        │
│  PW :                        │
│                              │
└──────────────────────────────┘
EOF
  )
  locoterm.mvaddstr(22, 35, 'Login failed!') if failed
  locoterm.refresh
end

def get_login_cred(locoterm)
  id = ''
  pw = ''
  locoterm.mvgetnstr(20, 40, id, 20)
  do_goodbye(locoterm) if id == 'off'
  locoterm.mvgetnstr(21, 40, pw, 20, echo: false)
  [id, pw]
end

def do_login(locoterm)
  user = nil
  tried = false
  until user
    draw_login(locoterm, failed: tried)
    tried = true
    id, pw = get_login_cred(locoterm)
    if id != 'new'
      user = User.find_by(username: id).try(:authenticate, pw)
    end
  end
  locoterm.current_user = user
end
