module TermApp
  class NanoEditor < Editor
    def edit(str: '')
      # TODO : alt key handling (http://stackoverflow.com/a/16248956)
      erase_all
      Line.set_column(@term.columns)
      str = "\n" if str == ''
      @lines = str.split("\n", -1).map { |x| Line.new(x) }
      i = 0
      @lines.each do |x|
        mvaddstr(i, 0, x.to_s)
        i = getyx[0] + 1
        break if i >= @term.lines
      end
      move(0, 0)
      Ncurses.noecho
      @start_y = 0
      @str_idx = 0
      @char_idx = 0
      @str_y_idx = 0
      ch = nil
      @screen_x = nil
      @navigating = false
      loop do
        @screen_x = nil unless @navigating
        @navigating = false
        if ch.nil?
          # FIXME : be more efficient
          erase_all
          i = 0
          @lines.each do |x|
            if i < @start_y
              if i + x.ymax <= @start_y
                i += x.ymax
                next
              else
                mvaddstr(0, 0, x.to_s(@start_y - i))
              end
            else
              mvaddstr(i - @start_y, 0, x.to_s)
            end
            i = getyx[0] + 1 + @start_y
            break if i >= @start_y + @term.lines
          end
          move(gety, @lines[@str_idx].x_pos(@str_y_idx, @char_idx))
          ch = get_wch
        end
        case ch[0]
        when Ncurses::OK
          case ch[1]
          when ctrl('j')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_ENTER]
            next
          when ctrl('a')
            @char_idx = 0
          when ctrl('b')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_LEFT]
            next
          when ctrl('d')
            # FIXME
          when ctrl('e')
            @char_idx = @lines[@str_idx].max_char_idx(@str_y_idx) - 1
          when ctrl('f')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_RIGHT]
            next
          when ctrl('k')
            # FIXME
          when ctrl('x')
            erase_all
            mvaddstr(0, 0, '(S)저장 (A)취소 (E)수정? [S] ')
            ch = get_wch
            case ch[2]
            when 'A', 'a'
              return nil
            when 'E', 'e'
              # nothing to do
            else
              break
            end
          when 127 # backspace
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_BACKSPACE]
            next
          else
            @str_y_idx, @char_idx = @lines[@str_idx].insert(@str_y_idx, @char_idx, ch[2])
          end
        when Ncurses::KEY_CODE_YES
          case ch[1]
          when Ncurses::KEY_BACKSPACE
            if @str_y_idx == 0 && @char_idx == 0
              if @str_idx == 0
                beep
              else
                prev_line = @lines[@str_idx - 1]
                @str_y_idx, @char_idx = prev_line.merge(@lines.delete_at(@str_idx))
                @str_idx -= 1
              end
            else
              @str_y_idx, @char_idx = @lines[@str_idx].delete(@str_y_idx, @char_idx)
            end
          when Ncurses::KEY_UP
            @navigating = true
            @screen_x = @lines[@str_idx]
                        .get_size_for_screen(@str_y_idx, @char_idx) unless @screen_x
            if @str_y_idx == 0
              if @str_idx == 0
                beep
              else
                @start_y -= 1 if gety == 0
                @str_idx -= 1
                @str_y_idx = @lines[@str_idx].ymax - 1
              end
            else
              @start_y -= 1 if gety == 0
              @str_y_idx -= 1
            end
            @char_idx = @lines[@str_idx].nearest_char_idx(@str_y_idx, @screen_x)
          when Ncurses::KEY_DOWN
            @navigating = true
            @screen_x = @lines[@str_idx]
                        .get_size_for_screen(@str_y_idx, @char_idx) unless @screen_x
            if @str_y_idx == @lines[@str_idx].ymax - 1
              if @str_idx == @lines.size - 1
                beep
              else
                @start_y += 1 if gety == @term.lines - 1
                @str_idx += 1
                @str_y_idx = 0
              end
            else
              @start_y += 1 if gety == @term.lines - 1
              @str_y_idx += 1
            end
            @char_idx = @lines[@str_idx].nearest_char_idx(@str_y_idx, @screen_x)
          when Ncurses::KEY_LEFT
            @char_idx -= 1 if @char_idx > 0
          when Ncurses::KEY_RIGHT
            @char_idx += 1 if @char_idx < @lines[@str_idx].max_char_idx(@str_y_idx)
          when Ncurses::KEY_ENTER
            @lines[@str_idx] = @lines[@str_idx].split(@str_y_idx, @char_idx)
            @lines.flatten!
            @str_idx += 1
            @str_y_idx = 0
            @char_idx = 0
          end
        end
        ch = nil
      end
      @lines.join("\n")
    end
    # end of def method edit

    def gety
      (@lines[0...@str_idx].map(&:ymax).inject(:+) || 0) + @str_y_idx - @start_y
    end
  end
  # end of def Class NanoEditor
end
