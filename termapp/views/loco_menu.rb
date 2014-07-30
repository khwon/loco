class LocoMenu < TermApp::View
  
  # Internal: Item of LocoMenu. Contains a regex for shortcut, title and a
  # method to be called when selected.
  class Item
    # Public: Returns the Regexp shortcut for the menu.
    attr_reader :shortcut_regex

    # Public: Returns the String title of the menu.
    attr_reader :title

    # Public: Returns the Method to be called when the menu is selected.
    attr_reader :menu

    # Public: Initialize a Item of LocoMenu.
    #
    # name   - A String indicates which menu it is.
    # method - The Method instance to be called when selected
    #          (default: LocoMenu.method(name.underscore.to_sym)).
    #
    # Examples
    #
    #   Item.new('Boards')
    #
    #   Item.new('New', LocoMenu.method(:read_new))
    def initialize(name, bind_menu)
      @shortcut_regex = Regexp.new("[#{name[0].upcase}#{name[0].downcase}]")
      @title = name.capitalize.sub(/^(.)/, '(\\1)')
      @menu = bind_menu
    end
  end

  def initialize(*args)
    @cur_menu = 0
    @past_menu = nil
    super
  end

  # Public: Main routine of LocoMenu. Show menus. User can navigate menus and
  # select a menu.
  #
  # locoterm - The LocoTerm instance to deal with screen.
  #
  # Returns nothing.
  def process
    items = []
    items << Item.new('New', :read_new_menu)
    items << Item.new('Boards', :print_board_menu)
    items << Item.new('Select', :select_board_menu)
    items << Item.new('Read', :read_board_menu)
    items << Item.new('Post', :post_menu)
    # items << Item.new('Extra')
    items << Item.new('Talk', :talk_menu)
    items << Item.new('Mail', :mail_menu)
    items << Item.new('Diary', :diary_menu)
    # items << Item.new('Visit')
    items << Item.new('Welcome', :welcome_menu)
    items << Item.new('Xyz', :xyz_menu)
    items << Item.new('Goodbye', :goodbye_menu)
    items << Item.new('Help', :help_menu)
    # items << Item.new('InfoBBS')
    items << Item.new('Admin', :admin_menu) if term.current_user.admin?
    menu_helper(items)
  end

  # Public: Helper for main of LocoMenu.
  #
  # locoterm - The LocoTerm instance to deal with screen.
  # items    - The Array of Item instances of menu to show.
  #
  # Examples
  #
  #   LocoMenu.menu_helper(
  #     locoterm,
  #     [
  #       Item.new('New', LocoMenu.method(:read_new)),
  #       Item.new('Boards'),
  #       Item.new('Select'),
  #       Item.new('Read'),
  #       Item.new('Post'),
  #       Item.new('Goodbye')
  #     ]
  #   )
  #
  # Returns nothing.
  def menu_helper(items)
    loop do
      term.noecho
      if @past_menu.nil?
        term.erase_body
        items.each_with_index do |item, i|
          if i == @cur_menu
            term.set_color(TermApp::Terminal::COLOR_BLACK, reverse: true) do
              term.mvaddstr(i + 4, 3, item.title)
            end
          else
            term.mvaddstr(i + 4, 3, item.title)
          end
        end
      else
        term.mvaddstr(@past_menu + 4, 3, items[@past_menu].title)
        term.set_color(TermApp::Terminal::COLOR_BLACK, reverse: true) do
          term.mvaddstr(@cur_menu + 4, 3, items[@cur_menu].title)
        end
      end
      term.move(@cur_menu + 4, 3)
      term.refresh
      case c = term.getch
      when Ncurses::KEY_UP
        @past_menu = @cur_menu
        @cur_menu = (@cur_menu - 1) % items.size
      when Ncurses::KEY_DOWN
        @past_menu = @cur_menu
        @cur_menu = (@cur_menu + 1) % items.size
      when Ncurses::KEY_ENTER, 10 # enter
        # Erase body after call
        @past_menu = nil
        term.echo
        break items[@cur_menu].menu
      else
        if c < 127
          items.each_with_index do |item, i|
            next unless c.chr =~ item.shortcut_regex
            @past_menu = @cur_menu
            @cur_menu = i
          end
        end
      end
    end
  end
end
