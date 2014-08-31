namespace :termapp do
  desc 'generate sample data for testing terminal app'
  task generate_data: :environment do
    if User.count == 0 && Board.count == 0
      puts 'Generating User data...'
      %w(a b c d).each do |x|
        u = User.new(username: x, password: x, nickname: x, realname: x,
                     sex: 'M', email: "#{x}@loco.kaist.ac.kr")
        u.save!
      end

      puts 'Generating Board data...'
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

      puts 'Linking User and Board...'
      arr.each do |board|
        %w(a b c d).each do |x|
          b = Board.new(name: x, is_dir: false)
          b.owner = User.all.sample
          b.parent = board
          b.save!
        end
      end

      puts 'Generating Post data...'
      Board.where(is_dir: false).each do |b|
        100.times do |i|
          post = Post.new(title: ["title_#{i}", "제목_#{i}"].sample * 50,
                          content:
                          '1234567890가나다라마바사' * 50 + "content_#{i}\n한글\n" * 20,
                          num: i + 1)
          post.board = b
          post.writer = User.all.sample
          post.save!
        end
      end
      puts 'Done.'
    else
      puts 'User and Board data exist in database. Empty your database first!'
    end
  end
end
