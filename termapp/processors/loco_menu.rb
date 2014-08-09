# Main processor of the Application. User can navigate menus and select a menu.
# Processed after WelcomeMenu.
class LocoMenu < TermApp::Processor
  # Item of LocoMenu. Contains a regex for shortcut, title and a menu symbol of
  # the class inheriting Processor.
  class Item
    # Returns the Regexp shortcut for the menu.
    attr_reader :shortcut_regex

    # Returns the String title of the menu.
    attr_reader :title

    # Returns the Symbol of the class inheriting Processor.
    attr_reader :menu

    # Initialize a Item of LocoMenu.
    #
    # name      - A String indicates which menu it is.
    # bind_menu - The Symbol of the class inheriting Processor of which the
    #             process method to be called when selected
    #             (default: "#{name}Menu".camelize.underscore.to_sym).
    #
    # Examples
    #
    #   Item.new('Post')
    #
    #   Item.new('New', :read_new_menu)
    def initialize(name, bind_menu = "#{name}Menu".camelize.underscore.to_sym)
      @shortcut_regex = Regexp.new("[#{name[0].upcase}#{name[0].downcase}]")
      @title = name.camelize.sub(/^(.)/, '(\\1)')
      @menu = bind_menu
    end
  end

  # Initialize a LocoMenu. Initialize cur_menu and past_menu.
  #
  # args - Zero or more values to pass to initialize of super class as
  #        parameters.
  #
  # Examples
  #
  #   LocoMenu.new(app)
  def initialize(*args)
    super
    @cur_menu = 0
    @past_menu = nil
    @items = [Item.new('New', :read_new_menu),
              Item.new('Boards', :print_board_menu),
              Item.new('Select', :select_board_menu),
              Item.new('Read', :read_board_menu)]
    @items.concat(%w(Post
                     Talk
                     Mail
                     Diary
                     Welcome
                     Xyz
                     Goodbye
                     Help).map { |name| Item.new(name) })
    # @items.concat(%w(Extra Visit InfoBBS).map { |name| Item.new(name) }))
    @items << Item.new('Admin') if term.current_user.admin?
    @items.freeze
  end

  # Main routine of LocoMenu. Show menus. User can navigate menus and select a
  # menu.
  #
  # Returns a Symbol of Processor with its process arguments or nil.
  def process
    loop do
      term.noecho
      if @past_menu.nil?
        print_items
      else
        term.mvaddstr(@past_menu + 4, 3, @items[@past_menu].title)
        term.color_black(reverse: true) do
          term.mvaddstr(@cur_menu + 4, 3, @items[@cur_menu].title)
        end
      end
      term.move(@cur_menu + 4, 3)
      term.refresh
      case c = term.getch
      when Ncurses::KEY_UP
        @past_menu = @cur_menu
        @cur_menu = (@cur_menu - 1) % @items.size
      when Ncurses::KEY_DOWN
        @past_menu = @cur_menu
        @cur_menu = (@cur_menu + 1) % @items.size
      when Ncurses::KEY_ENTER, 10 # enter
        # Erase body after call
        @past_menu = nil
        term.echo
        break @items[@cur_menu].menu
      else
        next unless c < 127
        @items.each_with_index do |item, i|
          next unless c.chr =~ item.shortcut_regex
          @past_menu = @cur_menu
          @cur_menu = i
        end
      end
    end
  end

  # Print items of menu.
  #
  # Returns nothing.
  def print_items
    term.erase_body
    @items.each_with_index do |item, i|
      if i == @cur_menu
        term.color_black(reverse: true) do
          term.mvaddstr(i + 4, 3, item.title)
        end
      else
        term.mvaddstr(i + 4, 3, item.title)
      end
    end
  end
end
