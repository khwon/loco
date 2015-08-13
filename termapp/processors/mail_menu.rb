require_relative 'loco_menu'
module TermApp
  # Corresponding Processor of MenuItem.new('Mail', :mail_menu).
  class MailMenu < LocoMenu
    def initialize(*args)
      super
      @items.concat [MenuItem.new('Send', :mail_send_menu),
                     MenuItem.new('Read', :mail_read_menu),
                     MenuItem.new('Outbox', :mail_outbox_menu),
                     MenuItem.new('Exit', :main_menu)]
      @items.freeze
    end
  end

  class MailSendMenu < Processor
    def process
      :mail_menu
    end
  end

  class MailReadMenu < Processor
    def process
      :mail_menu
    end
  end

  class MailOutboxMenu < Processor
    def process
      :mail_menu
    end
  end
end
