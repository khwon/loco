require_relative 'loco_menu'
module TermApp
  # Main processor of the Application. User can navigate menus and select a
  # menu. Processed after WelcomeMenu.
  class MainMenu < LocoMenu
    # Initialize a MainMenu. Initialize cur_menu and past_menu.
    #
    # args - Zero or more values to pass to initialize of super class as
    #        parameters.
    #
    # Examples
    #
    #   MainMenu.new(app)
    def initialize(*args)
      super
      @items.concat [Item.new('New', :read_new_menu),
                     Item.new('Boards', :print_board_menu),
                     Item.new('Select', :select_board_menu),
                     Item.new('Read', :read_board_menu)]
      @items.concat(
        %w(Post Talk Mail Diary Welcome Xyz Goodbye Help)
          .map { |name| Item.new(name) })
      # @items.concat(%w(Extra Visit InfoBBS).map { |name| Item.new(name) }))
      @items << Item.new('Admin') if term.current_user.admin?
      @items.freeze
    end
  end
end
