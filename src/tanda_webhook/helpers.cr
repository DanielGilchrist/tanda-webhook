module Tanda::Webhook
  module Helpers
    extend self

    def pretty_print_obj(header, obj)
      puts
      puts header
      pp obj
      puts
    end
  end
end
