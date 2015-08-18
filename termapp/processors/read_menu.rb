module TermApp
  # Generalized read-helper class. Others can inherit this class
  # to implement read-sth menu processor.
  class ReadMenu < Processor
    def initialize(app)
      super
    end
    # Hook called before process_init
    # returning symbol of menu causes stop process
    def before_process_init
      nil
    end
    # Hook called after process_init
    # returning symbol of menu causes stop process
    def after_process_init
      nil
    end

    def process
      term.erase_body
      print_header
      result = before_process_init
      return result unless result.nil?
      process_init
      result = after_process_init
      return result unless result.nil?
      term.noecho
      result = loop do
        sanitize_current_index
        print_items
        @past_index = @cur_index
        control, *args = process_key(term.get_wch)
        while control
          control, *args =
            case control
            when :break then break args
            when :beep
              term.beep
              nil
            when :scroll
              scroll(*args)
              nil
            when :read
              read_item(args[0])
            when :reply
              write_item(args[0])
              process_init
              nil
            when :read_next
              if @cur_index == @list_size - 1 && !scrollable?(:down)
                nil
              else
                if @cur_index == @list_size - 1
                  scroll :down
                else
                  @cur_index += 1
                end
                [:read, @items[@cur_index]]
              end
            when :read_prev
              if @cur_index == 0 && !scrollable?(:up)
                nil
              else
                if @cur_index == 0
                  scroll :up
                else
                  @cur_index -= 1
                end
                [:read, @items[@cur_index]]
              end
            else
              process_hooks(control, args)
            end
        end
        break args if control == :break
      end
      term.echo
      result
    end

    def process_hooks
      nil
    end

    private

    # Initialize instance variables before actual processing.
    #
    # Returns nothing.
    def process_init
      @cur_index = nil
      @past_index = nil
      @list_size = term.lines - 5
      @item_list = items
      @list_size = @item_list.size if @item_list.size < @list_size
      @edge_items = get_edge_items
    end

    def items
      []
    end

    def get_edge_items
      []
    end

    def item_idx(_item)
      fail NotImplementedError
    end

    def count_items(_from: nil, _to: nil)
      fail NotImplementedError
    end

    # Process key input for ReadBoardMenu.
    #
    # key - An Array of key input which is returned from term.get_wch.
    #
    # Returns nil or a Symbol :beep, :scroll_down, :scroll_up or :break with
    #   additional arguments.
    def process_key(key)
      tmp_num = @num || ''
      @num = ''
      case KeyHelper.key_symbol(key)
      when :esc, :q, :e
        return :break, @prev_menu
      when :space, :r
        return :break, @prev_menu unless @item_list[@cur_index]
        return :read, @item_list[@cur_index]
      when :R
        return :reply, @item_list[@cur_index]
      when :enter
        @pivot = get_pivot(tmp_num.to_i)
        return :scroll, :around if @pivot
        return :beep
      when :'$'
        return :scroll, :bottom
      when :ctrl_u, :P
        return :scroll, :up, preserve_position: true
      when :ctrl_d, :N
        return :scroll, :down, preserve_position: true
      when :j, :down, :n
        return :scroll, :down if @cur_index == @list_size - 1
        @cur_index += 1
      when :k, :up, :p
        return :scroll, :up if @cur_index == 0
        @cur_index -= 1
      when :ctrl_p
        return :write
      when *(0..9).map(&:to_s).map(&:to_sym)
        @num = tmp_num
        @num += key[2]
        return :nothing
      else
        return :beep
      end
    end

    def get_pivot(_num)
      nil
    end

    # Ensure the current index is not out of the range.
    #
    # Returns nothing.
    def sanitize_current_index
      return unless @cur_index.nil? || @cur_index >= @list_size
      @cur_index = @list_size - 1
    end

    # Check if the page can be scrolled with given direction.
    #
    # direction - A Symbol one of :bottom, :down or :up.
    #
    # Returns a Boolean whether the page can be scrolled.
    def scrollable?(direction)
      case direction
      when :bottom, :down
        pivot = @item_list[-1]
        return pivot && pivot != @edge_items[1]
      when :up
        pivot = @item_list[0]
        return pivot && pivot != @edge_items[0]
      when :around
        return true
      end
    end

    # Scroll the page of Items.
    #
    # direction - A Symbol indicates direction. It can be :bottom, :down or :up.
    # options   - The Hash options used to control position of cursor
    #             (default: { preserve_position: false }).
    #             :preserve_position - The Boolean whether to preserve current
    #                                  position of cursor or not (optional).
    #
    # Examples
    #
    #   scroll(:down)
    #
    #   scroll(:up, preserve_position: true)
    #
    # Returns nothing.
    def scroll(direction, preserve_position: false)
      unless scrollable?(direction)
        case direction
        when :bottom, :down
          @cur_index = @list_size - 1
        when :up
          @cur_index = 0
        else
          term.beep
        end
        return
      end
      @past_index = nil
      case direction
      when :bottom
        @cur_index = @list_size - 1
        @item_list = items
      when :down
        @cur_index = 1 unless preserve_position
        @item_list = items(from: item_idx(@item_list[-1]))
        if @item_list.size < @list_size # reached last
          @cur_index = @list_size - @item_list.size + 1 unless preserve_position
          @item_list = items
        end
      when :up
        @cur_index = @list_size - 2 unless preserve_position
        @item_list = items(to: item_idx(@item_list[0]))
        if @item_list.size < @list_size # reached first
          @cur_index = @item_list.size - 2 unless preserve_position
          @item_list = items(from: 1)
        end
      when :around
        if count_items(to: item_idx(@pivot)) <= @list_size / 2
          # goto first page
          @item_list = items(from: 1)
          @cur_index = @item_list.index(@pivot)
        elsif count_items(from: item_idx(@pivot)) <= @list_size / 2
          # goto last page
          @item_list = items
          @cur_index = @item_list.index(@pivot)
        else
          @item_list = items(to: item_idx(@pivot), size: @list_size / 2)
          @item_list += items(from: item_idx(@pivot) + 1,
                              size: @list_size - @item_list.size)
          @cur_index = @item_list.index(@pivot)
        end
      end
      after_scroll
    end

    def after_scroll
    end

    def print_header
    end

    # Print Item list. Current Item is displayed in reversed color. Refresh only
    # highlighted lines if the list hasn't been scrolled.
    #
    # Returns nothing.
    def print_items(range: nil)
      if @past_index.nil?
        term.erase_body
        print_header
        @item_list.each_with_index do |item, i|
          print_item(item, i, x: 0, reverse: @cur_index == i)
        end
      elsif range
        range.each do |i|
          print_item(@item_list[i], i, x: 0, reverse: @cur_index == i)
        end
      else
        return if @past_index == @cur_index
        print_item(@item_list[@past_index], @past_index, x: 0)
        print_item(@item_list[@cur_index], @cur_index, x: 0, reverse: true)
      end
      term.mvaddstr(@cur_index + 4, 0, '>')
      term.refresh
    end

    # See Processor#item_title.
    #
    # item - Some instance to print.
    #
    # Returns the String title of the Item.
    def item_title(item)
      item.format_for_term(term.columns - 32)
    end

    def item_block(_item, &block)
      block.yield
    end
  end
end
