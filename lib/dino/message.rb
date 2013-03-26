module Dino
  module Message
    def self.encode(options={})
      cmd = options[:command]
      pin = options[:pin]
      val = options[:value]
      aux = options[:aux_message]
      aux.gsub!("\n", "\\\n") if aux

      raise Exception.new('commands must be specified') unless cmd
      raise Exception.new('commands can only be four digits') if cmd.to_s.length > 4
      raise Exception.new('pins can only be four digits') if pin.to_s.length > 4
      raise Exception.new('values can only be four digits') if val.to_s.length > 4
      raise Exception.new('auxillary messages are limited to 255 characters') if aux.to_s.length > 255

      message = "#{cmd}"
      if pin
        message << ".#{pin}"
      end
      if val
        message << "." unless pin
        message << ".#{val}"
      end
      if aux
        message << "." unless pin
        message << "." unless val
        message << ".#{aux}"
      end
      message << "\n"
      message
    end
  end
end
