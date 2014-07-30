require 'ncursesw'
require_relative 'locoterm'

def draw_main(locoterm)
  locoterm.clrtoeol(0..2)
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

  locoterm.color_white do
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
  locoterm.refresh
end

locoterm = nil
begin
  locoterm = LocoTerm.new
  draw_main(locoterm)
  sleep(2.5)
  gets
rescue
  $stderr.puts $ERROR_INFO
  $stderr.puts $ERROR_POSITION
ensure
  locoterm.terminate
end
