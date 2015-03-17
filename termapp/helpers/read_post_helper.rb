module TermApp
  # Helper methods for reading Posts. See ReadBoardMenu.
  class ReadPostHelper < Helper
    # Initialize a ReadPostHelper. It holds an Application instance and a model.
    #
    # app   - The Application instance which is now running.
    # model - A model instance to show.
    def initialize(app, model)
      @app = app
      @model = model
    end

    # Show content of the model to terminal. Currently it shows Post only.
    #
    # Returns nothing.
    def read_post
      return unless @model.is_a?(Post)
      if @model.read_status != 'R'
        BoardRead.mark_read(term.current_user, @model, @model.board)
      end
      term.erase_all
      str = ''
      str << "글쓴이 : #{@model.writer.username} (#{@model.writer.nickname})\n"
      str << "날  짜 : #{@model.created_at}\n"
      str << "제  목 : #{@model.title.unicode_slice(term.columns - 10)}\n\n"
      str << @model.content
      editor = term.readonly_editor.new(term)
      editor.exit_on = %i(n p)
      editor.show(str: str)
    end
  end
end
