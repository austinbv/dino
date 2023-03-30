# encoding: ascii-8bit
# For convenience when validating longer data types.

require_relative '../../test_helper'

class APIHelperTest < Minitest::Test
  include Dino::Board::API::Helper
  
  def test_single_integers
    assert_equal pack(:uint8, 25), "\x19"
  end
  
  def test_other_formats
    assert_equal pack(:uint16, 5*10**4),  "P\xC3"
    assert_equal pack(:uint32, 4*10**9),  "\x00(k\xEE"
    assert_equal pack(:uint64, 9*10**18), "\x00\x00\x84\xE2Pl\xE6|"
  end
  
  def test_array
    assert_equal pack(:uint8, [25,26]), "\x19\x1A"
  end
  
  def test_padding
    assert_equal pack(:uint8, 25, pad: 2), "\x19\x00"
  end
  
  def test_min
    assert_raises(ArgumentError) { pack(:uint8, 25, min: 2) }
  end
  
  def test_max
    assert_raises(ArgumentError) { pack(:uint8, [25,26,27], max: 2) }
  end
  
  def test_invalid_formats
    assert_raises(ArgumentError) { pack(:uint128, 25) }
  end
end
