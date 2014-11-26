module TermApp
  # Process login screen. Processed at first. Terminate the Application when
  # user input 'off' on id field.
  class LoginMenu < Processor
    LOGO = []
    LOGO << <<END.freeze
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
END
    LOGO << <<END.freeze
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
END
    LOGO << <<END.freeze
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
END
    LOGO << <<END.freeze
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
END
    LOGO.freeze
    private_constant :LOGO

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
          user = User.find_by(username: id).auth(pw)
        end
      end
      term.current_user = user
      :welcome_menu
    end

    private

    # Draw login page with the logo of Loco.
    #
    # options - The Hash options used to print login failed message
    #           (default: { failed: false }):
    #           :failed - The Boolean indicates whether user has failed to login
    #                     or not (optional).
    #
    # Examples
    #
    #   draw_login
    #
    #   draw_login(failed: true)
    #
    # Returns nothing.
    def draw_login(failed: false)
      term.clrtoeol(0..23)
      draw_logo
      term.color_white do
        term.mvaddstr(13, 50, 'managed by GoN security')
        term.mvaddstr(14, 52, 'since 1999')
      end
      term.mvaddstr(20, 5, 'total hit: 14520652')
      term.mvaddstr(21, 5, 'today hit: 229')
      draw_login_form
      term.mvaddstr(22, 35, 'Login failed!') if failed
      term.refresh
    end

    # Draw logo of Loco. Each character of logo is colored randomly. If every
    # letter has same color, print 'JACKPOT!!!!' on screen.
    #
    # Returns nothing.
    def draw_logo
      logo_colors = []
      [[2, 2], [5, 15], [3, 33], [2, 51]].each_with_index do |point, i|
        y, x = point
        logo_colors << term.color_sample { term.print_block(y, x, LOGO[i]) }
      end
      return if logo_colors.uniq.size > 1
      term.color_red { term.mvaddstr(18, 17, 'JACKPOT!!!!') }
    end

    # Draw login form.
    #
    # Returns nothing.
    def draw_login_form
      term.print_block(17, 32, <<END.freeze)
   type 'new' to join
   there is no guest ID
┌──────────────────────────────┐
│  ID :                        │
│  PW :                        │
│                              │
└──────────────────────────────┘
END
    end
  end
end
