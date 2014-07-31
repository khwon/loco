namespace :termapp do
  desc 'generate sample data for testing terminal app'
  task generate_data: :environment do
    if User.count == 0 && Board.count == 0
      %w(a b c d).each do |x|
        u = User.new(username: x, password: x, nickname: x, realname: x,
                     sex: 'M', email: "#{x}@loco.kaist.ac.kr")
        u.save!
      end

      arr = []
      %w(Korea
         hackers
         asia
         europe
         northAmerica
         southAmerica
         oceania
         Africa
      ).each do |x|
        b = Board.new(name: x, is_dir: true)
        b.save!
        arr << b
      end

      arr.each do |board|
        %w(a b c d).each do |x|
          b = Board.new(name: x, is_dir: false)
          b.owner = User.all.sample
          b.parent = board
          b.save!
        end
      end

      Board.where(is_dir: false).each do |b|
        10.times do |i|
          post = Post.new(title: "title_#{i}", content: "content_#{i}\n" * 20, num: i+1)
          post.board = b
          post.writer = User.all.sample
          post.save!
        end
      end
    else
      puts 'empty your db first!'
    end
  end
end
