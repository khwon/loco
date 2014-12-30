class BoardRead < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  def self.mark_read(user, post, board = nil)
    board = post.board unless board
    board = board.alias_board while board.alias_board
    num = post.num
    around_models = BoardRead.where('user_id = ? and board_id = ?',
                                    user.id, board.id)
                    .where('posts && int4range(?,?)', num - 1, num + 2)
    cur_model = nil
    stats = ['N'] * 3
    nums = [num - 1, num, num + 1]
    around_models.each do |x|
      nums.each_with_index do |n, i|
        stats[i] = x[:status] if x.posts.include? n
      end
      cur_model = x if x.posts.include? num
    end
    return if stats[1] == 'R' # nothing to do
    if cur_model
      if cur_model.posts.min == num && cur_model.posts.max == num
        cur_model.destroy!
      elsif cur_model.posts.max == num
        cur_model.posts = (cur_model.posts.min..(num - 1))
        cur_model.save!
      elsif cur_model.posts.min == num
        cur_model.posts = ((num + 1)..cur_model.posts.max)
        cur_model.save!
      else
        br = BoardRead.new
        br.user = user
        br.board = board
        br.posts = ((num + 1)..cur_model.posts.max)
        br.status = cur_model[:status]
        br.save!
        cur_model.posts = (cur_model.posts.min..(num - 1))
        cur_model.save!
      end
    end
    prev_st = around_models.find do |x|
      x.posts.max == num - 1 && x[:status] == 'R'
    end
    next_st = around_models.find do |x|
      x.posts.min == num + 1 && x[:status] == 'R'
    end
    if stats[0] == 'R' && stats[2] == 'R'
      fail if prev_st.nil? || next_st.nil?
      prev_st.posts = (prev_st.posts.min..next_st.posts.max)
      prev_st.save!
      next_st.destroy!
    elsif stats[0] == 'R'
      fail if prev_st.nil?
      prev_st.posts = (prev_st.posts.min..num)
      prev_st.save!
    elsif stats[2] == 'R'
      fail if next_st.nil?
      next_st.posts = (num..next_st.posts.max)
      next_st.save!
    else
      br = BoardRead.new
      br.user = user
      br.board = board
      br.posts = (num..num)
      br.status = 'R'
      br.save!
    end
  end

  def self.mark_visit(user, post, board = nil)
    board = post.board unless board
    board = board.alias_board while board.alias_board
    num = post.num
    around_models = BoardRead.where('user_id = ? and board_id = ?',
                                    user.id, board.id)
                    .where('posts && int4range(?,?)', num - 1, num + 2)
    cur_model = nil
    stats = ['N'] * 3
    nums = [num - 1, num, num + 1]
    around_models.each do |x|
      nums.each_with_index do |n, i|
        stats[i] = x[:status] if x.posts.include? n
      end
      cur_model = x if x.posts.include? num
    end
    return if stats[1] != 'N' # nothing to do
    prev_st = around_models.find do |x|
      x.posts.max == num - 1 && x[:status] == 'V'
    end
    next_st = around_models.find do |x|
      x.posts.min == num + 1 && x[:status] == 'V'
    end
    if stats[0] == 'V' && stats[2] == 'V'
      fail if prev_st.nil? || next_st.nil?
      prev_st.posts = (prev_st.posts.min..next_st.posts.max)
      prev_st.save!
      next_st.destroy!
    elsif stats[0] == 'V'
      fail if prev_st.nil?
      prev_st.posts = (prev_st.posts.min..num)
      prev_st.save!
    elsif stats[2] == 'V'
      fail if next_st.nil?
      next_st.posts = (num..next_st.posts.max)
      next_st.save!
    else
      br = BoardRead.new
      br.user = user
      br.board = board
      br.posts = (num..num)
      br.status = 'V'
      br.save!
    end
  end
end
