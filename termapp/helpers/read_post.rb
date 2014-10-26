module TermApp
  class ReadPostHelper
    def initialize(app, model)
      @app = app
      @model = model
    end

    def show
      term = @app.term # TODO : just for convinience, not a good design
      return unless @model.is_a? Post
      term.erase_all
      term.mvaddstr(0, 0, "글쓴이 : #{@model.writer.username} (#{@model.writer.nickname})")
      term.mvaddstr(1, 0, "날  짜 : #{@model.created_at}")
      term.mvaddstr(2, 0, "제  목 : #{@model.title.unicode_slice(term.columns - 10)}")
      # FIXME : implement appropriate printing!
      term.mvaddstr(4, 0, @model.content)
      term.getch
      :loco_menu
    end
  end
end
