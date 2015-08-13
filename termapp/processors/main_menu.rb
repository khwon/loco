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
      @items.concat [MenuItem.new('New', :read_new_menu),
                     MenuItem.new('Boards', :print_board_menu),
                     MenuItem.new('Select', :select_board_menu),
                     MenuItem.new('Read', :read_board_menu)]
      @items.concat(
        %w(Post Talk Mail Diary Welcome Xyz Goodbye Help)
          .map { |name| MenuItem.new(name) })
      # @items.concat(%w(Extra Visit InfoBBS).map { |name| MenuItem.new(name) }))
      @items << MenuItem.new('Admin') if term.current_user.admin?
      @items.freeze
    end
  end
end
