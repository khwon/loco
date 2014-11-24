module TermApp
  # Nano editor for terminal. Used for writing posts. Handle Emacs shortcuts.
  class NanoEditor < Editor
    def edit(str: '')
      # TODO: alt key handling (http://stackoverflow.com/a/16248956).
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
      key = nil
      @screen_x = nil
      @navigating = false
      loop do
        @screen_x = nil unless @navigating
        @navigating = false
        if key.nil?
          # OPTIMIZE: Be more efficient.
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
          key = get_wch
        end
        case KeyHelper.key_symbol(key)
        when :ctrl_j, :enter
          @lines[@str_idx] = @lines[@str_idx].split(@str_y_idx, @char_idx)
          @lines.flatten!
          @str_idx += 1
          @str_y_idx = 0
          @char_idx = 0
        when :ctrl_a
          @char_idx = 0
        when :ctrl_b, :left
          @char_idx -= 1 if @char_idx > 0
        when :ctrl_d
          # FIXME
        when :ctrl_e
          @char_idx = @lines[@str_idx].max_char_idx(@str_y_idx) - 1
        when :ctrl_f, :right
          @char_idx += 1 if @char_idx <
                            @lines[@str_idx].max_char_idx(@str_y_idx)
        when :ctrl_k
          # FIXME
        when :ctrl_x
          erase_all
          mvaddstr(0, 0, '(S)저장 (A)취소 (E)수정? [S] ')
          key = get_wch
          case key[2]
          when 'A', 'a'
            return nil
          when 'E', 'e'
            # Nothing to do.
          else
            break
          end
        when :backspace
          if @str_y_idx == 0 && @char_idx == 0
            if @str_idx == 0
              beep
            else
              prev_line = @lines[@str_idx - 1]
              @str_y_idx, @char_idx = prev_line
                                      .merge(@lines.delete_at(@str_idx))
              @str_idx -= 1
            end
          else
            @str_y_idx, @char_idx = @lines[@str_idx]
                                    .delete(@str_y_idx, @char_idx)
          end
        when :up
          @navigating = true
          unless @screen_x
            @screen_x = @term.getyx[1]
          end
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
        when :down
          @navigating = true
          unless @screen_x
            @screen_x = @term.getyx[1]
          end
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
        else
          if key[0] == Ncurses::OK
            @str_y_idx, @char_idx = @lines[@str_idx]
                                    .insert(@str_y_idx, @char_idx, key[2],
                                            getyx[1])
          end
        end
        key = nil
      end
      @lines.join("\n")
    end
    # End of def method edit.

    def gety
      (@lines[0...@str_idx].map(&:ymax).reduce(:+) || 0) + @str_y_idx - @start_y
    end
  end
  # End of def class NanoEditor.
end
