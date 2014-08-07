class LoginMenu < TermApp::Processor
  def process
    user = nil
    tried = false
    until user
      id = ''
      pw = ''
      draw_login(failed: tried)
      tried = true
      term.mvgetnstr(20, 40, id, 20)
      return :goodbye_menu if id == 'off'
      term.mvgetnstr(21, 40, pw, 20, echo: false)
      if id != 'new'
        user = User.find_by(username: id).try(:authenticate, pw)
      end
    end
    term.current_user = user
    :welcome_menu
  end

  private

  def draw_login(failed: false)
    term.clrtoeol(0..23)
    logo_colors = []
    logo_colors << term.color_sample do
      term.print_block(2, 2, <<EOF
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

    logo_colors << term.color_sample do
      term.print_block(5, 15, <<EOF
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

    logo_colors << term.color_sample do
      term.print_block(3, 33, <<EOF
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

    logo_colors << term.color_sample do
      term.print_block(2, 51, <<EOF
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

    term.color_white do
      term.mvaddstr(13, 50, 'managed by GoN security')
      term.mvaddstr(14, 52, 'since 1999')
    end
    if logo_colors.uniq.size == 1
      term.color_red { term.mvaddstr(18, 17, 'JACKPOT!!!!') }
    end
    term.mvaddstr(20, 5, 'total hit: 14520652')
    term.mvaddstr(21, 5, 'today hit: 229')
    term.print_block(17, 32, <<EOF
   type 'new' to join
   there is no guest ID
┌──────────────────────────────┐
│  ID :                        │
│  PW :                        │
│                              │
└──────────────────────────────┘
EOF
    )
    term.mvaddstr(22, 35, 'Login failed!') if failed
    term.refresh
  end
end
