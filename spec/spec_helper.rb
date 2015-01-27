require 'rspec'

require File.expand_path(File.join('../..', 'lib/smalrubot'), __FILE__)

# Nice little helper module to redefine constants quietly.
module Constants
  def self.redefine(const, value, opts={})
    opts = {:on => self.class}.merge(opts)
    opts[:on].send(:remove_const, const) if self.class.const_defined?(const)
    opts[:on].const_set(const, value)
  end
end
