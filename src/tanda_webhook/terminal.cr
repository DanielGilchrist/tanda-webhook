module Tanda::Webhook
  class Terminal
    record Window, columns : UInt32?

    def window : Window
      Window.new(columns)
    end

    private def columns : UInt32?
      {% if flag?(:linux) || flag?(:darwin) %}
        `tput cols`.to_u32?
      {% else %}
        nil
      {% end %}
    end
  end
end
