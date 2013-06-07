module Dino
  module Message
    def self.encode(options={})
      cmd = options[:command]
      pin = options[:pin]
      val = options[:value]
      aux = options[:aux_message]
      aux.to_s.gsub!("\n", "\\\n") if aux

      raise Exception.new('commands must be specified') unless cmd
      raise Exception.new('commands can only be four digits') if cmd.to_s.length > 4
      raise Exception.new('pins can only be four digits') if pin.to_s.length > 4
      raise Exception.new('values can only be four digits') if val.to_s.length > 4
      raise Exception.new('auxillary messages are limited to 255 characters') if aux.to_s.length > 255

      message = ""
      [aux, val, pin].each do |fragment|
        if fragment
          message = ".#{fragment}" << message
        elsif !message.empty?
          message = "." << message
        end
      end
      message = "#{cmd}" << message
      message << "\n"
    end
  end
end
