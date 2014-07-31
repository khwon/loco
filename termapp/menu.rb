require_relative 'locoterm'
require_relative 'welcome'
require_relative 'goodbye'
require_relative 'board'
class LocoMenu
  # Internal: Item of LocoMenu. Contains a regex for shortcut, title and a
  # method to be called when selected.
  class Item
    # Public: Returns the Regexp shortcut for the menu.
    attr_reader :shortcut_regex

    # Public: Returns the String title of the menu.
    attr_reader :title

    # Public: Returns the Method to be called when the menu is selected.
    attr_reader :method

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
    def initialize(name, method = LocoMenu.method(name.underscore.to_sym))
      @shortcut_regex = Regexp.new("[#{name[0].upcase}#{name[0].downcase}]")
      @title = name.capitalize.sub(/^(.)/, '(\\1)')
      @method = method
    end
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
  def self.menu_helper(locoterm, items)
    cur_menu = 0
    past_menu = nil
    loop do
      locoterm.noecho
      if past_menu.nil?
        locoterm.erase_body
        items.each_with_index do |item, i|
          if i == cur_menu
            locoterm.color_black(reverse: true) do
              locoterm.mvaddstr(i + 4, 3, item.title)
            end
          else
            locoterm.mvaddstr(i + 4, 3, item.title)
          end
        end
      else
        locoterm.mvaddstr(past_menu + 4, 3, items[past_menu].title)
        locoterm.color_black(reverse: true) do
          locoterm.mvaddstr(cur_menu + 4, 3, items[cur_menu].title)
        end
      end
      locoterm.move(cur_menu + 4, 3)
      locoterm.refresh
      case c = locoterm.getch
      when Ncurses::KEY_UP
        past_menu = cur_menu
        cur_menu = (cur_menu - 1) % items.size
      when Ncurses::KEY_DOWN
        past_menu = cur_menu
        cur_menu = (cur_menu + 1) % items.size
      when Ncurses::KEY_ENTER, 10 # enter
        # Erase body after call
        past_menu = nil
        locoterm.echo
        items[cur_menu].method.call(locoterm)
      else
        if c < 127
          items.each_with_index do |item, i|
            next unless c.chr =~ item.shortcut_regex
            past_menu = cur_menu
            cur_menu = i
          end
        end
      end
    end
  end

  # Public: Main routine of LocoMenu. Show menus. User can navigate menus and
  # select a menu.
  #
  # locoterm - The LocoTerm instance to deal with screen.
  #
  # Returns nothing.
  def self.main(locoterm)
    items = []
    items << Item.new('New', LocoMenu.method(:read_new))
    items << Item.new('Boards')
    items << Item.new('Select')
    items << Item.new('Read')
    items << Item.new('Post')
    # items << Item.new('Extra')
    items << Item.new('Talk')
    items << Item.new('Mail')
    items << Item.new('Diary')
    # items << Item.new('Visit')
    items << Item.new('Welcome')
    items << Item.new('Xyz')
    items << Item.new('Goodbye')
    items << Item.new('Help')
    # items << Item.new('InfoBBS')
    items << Item.new('Admin') if locoterm.current_user.admin?
    LocoMenu.menu_helper(locoterm, items)
  end

  def self.admin(locoterm)
    # FIXME: admin
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'admin: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.read_new(locoterm)
    # FIXME: read_new
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'read_new: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.boards(locoterm)
    print_board(locoterm)
  end

  def self.select(locoterm)
    select_board(locoterm)
  end

  def self.read(locoterm)
    # FIXME: read
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'read: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.post(locoterm)
    # FIXME: post
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'post: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.talk(locoterm)
    # FIXME: talk
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'talk: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.mail(locoterm)
    # FIXME: mail
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'mail: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.diary(locoterm)
    # FIXME: diary
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'diary: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.welcome(locoterm)
    show_welcome(locoterm)
  end

  def self.xyz(locoterm)
    # FIXME: xyz
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'xyz: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end

  def self.goodbye(locoterm)
    do_goodbye(locoterm)
  end

  def self.help(locoterm)
    # FIXME: help
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, 'help: Not supported yet')
    locoterm.refresh
    locoterm.getch
  end
end
