module TermApp
  # Corresponding Processor of LocoMenu::Item.new('Post', :post_menu).
  class PostMenu < Processor
    def process
      write_helper = WriteHelper.new(@app)
      write_helper.write
      :read_board_menu
    end
  end
end
