require 'test_helper'

class OneWireHelper < Minitest::Test
  
  def test_with_valid_crc
    assert Dino::Components::OneWire::Helper.crc_check(18086456125349333800)
    assert Dino::Components::OneWire::Helper.crc_check([121, 117, 144, 185, 6, 165, 43, 26])
  end
  
  def test_with_invalid_crc
    refute Dino::Components::OneWire::Helper.crc_check(18086456125349333801)
  end
  
  def test_arbitrary_length_read
    assert Dino::Components::OneWire::Helper.crc_check([181, 1, 75, 70, 127, 255, 11, 16, 163])
    refute Dino::Components::OneWire::Helper.crc_check([181, 1, 75, 70, 127, 255, 11, 16, 164])
  end
end
