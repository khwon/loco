module TermApp
  # Helper methods for processing key input.
  class KeyHelper < Helper
    # Hash of key codes returned when the status code of Terminal#get_wch is
    # Ncurses::OK.
    KEY_CODES = { 9   => :tab,
                  10  => :enter,
                  27  => :esc,
                  32  => :space,
                  127 => :backspace }.freeze
    private_constant :KEY_CODES

    # Hash of key codes returned when the status code of Terminal#get_wch is
    # Ncurses::KEY_CODE_YES.
    NCURSES_KEY_CODES = { Ncurses::KEY_ENTER     => :enter,
                          Ncurses::KEY_BACKSPACE => :backspace,
                          Ncurses::KEY_UP        => :up,
                          Ncurses::KEY_DOWN      => :down,
                          Ncurses::KEY_LEFT      => :left,
                          Ncurses::KEY_RIGHT     => :right }.freeze
    private_constant :NCURSES_KEY_CODES

    # Classify the key returned by Terminal#get_wch into a symbol.
    #
    # key - The Array returned by Terminal#get_wch.
    #
    # Returns a Symbol type of the key input.
    def self.key_symbol(key)
      status, key_code, str = key
      case status
      when Ncurses::OK
        if KEY_CODES.key?(key_code)
          KEY_CODES[key_code]
        elsif 1 <= key_code && key_code <= 31
          :"ctrl_#{(key_code + 64).chr.downcase}"
        elsif key_code < 127
          str.to_sym
        end
      when Ncurses::KEY_CODE_YES
        NCURSES_KEY_CODES[key_code]
      end
    end
  end
end
