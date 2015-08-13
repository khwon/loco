module TermApp
  # Item of LocoMenu. Contains a regex for shortcut, title and a menu symbol
  # of the class inheriting Processor.
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

  # Generalized menu-helper class. Others can inherit this class
  # to implement menu-like processor.
  class LocoMenu < Processor
    # Initialize a LocoMenu. Initialize cur_menu and past_menu.
    #
    # args - Zero or more values to pass to initialize of super class as
    #        parameters.
    #
    # Examples
    #
    def initialize(*args)
      super
      @cur_menu = 0
      @past_menu = nil
      @items = []
    end

    # Main routine of LocoMenu. Show menus. User can navigate menus and select a
    # menu.
    #
    # selected_menu - The Symbol of Processor to be processed (default: nil).
    #
    # Returns a Symbol of Processor with its process arguments or nil.
    def process(selected_menu = nil)
      @cur_menu = @items.index { |x| x.menu == selected_menu } if selected_menu

      loop do
        term.noecho
        print_items
        term.move(@cur_menu + 4, 3)
        term.refresh
        control, *args = process_key(term.get_wch)
        case control
        when :break
          break args
        end
      end
    end

    private

    # Process key input for LocoMenu.
    #
    # key - An array of key input which is returned from term.get_wch.
    #
    # Examples
    #
    #   process_key(term.get_wch)
    #
    #   process_key(10)
    #   # => [:break, :welcome_menu]
    #
    # Returns nil or a Symbol :break with additional arguments.
    def process_key(key)
      case KeyHelper.key_symbol(key)
      when :up
        @past_menu = @cur_menu
        @cur_menu = (@cur_menu - 1) % @items.size
      when :down
        @past_menu = @cur_menu
        @cur_menu = (@cur_menu + 1) % @items.size
      when :enter
        # Erase body after call
        @past_menu = nil
        term.echo
        return :break, @items[@cur_menu].menu
      end

      return if key[0] != Ncurses::OK
      @items.each_with_index do |item, i|
        next unless key[2] =~ item.shortcut_regex
        @past_menu = @cur_menu
        @cur_menu = i
      end
    end

    # Print Items of menu. Refresh only changed lines if past_menu exists.
    #
    # Returns nothing.
    def print_items
      if @past_menu.nil?
        term.erase_body
        @items.each_with_index do |item, i|
          print_item(item, i, reverse: i == @cur_menu)
        end
      else
        print_item(@items[@past_menu], @past_menu)
        print_item(@items[@cur_menu], @cur_menu, reverse: true)
      end
    end

    # See Processor#item_title.
    #
    # item - The Item instance to print.
    #
    # Returns the title of the Item.
    def item_title(item)
      item.title
    end
  end
end
