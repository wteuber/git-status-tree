# encoding: utf-8

class TestCodeQuality < Test::Unit::TestCase

  def test_cane
    if ENV['RUBY_VERSION'][0..9] >= 'ruby-1.9.0'
      require 'bundler/setup'
      assert_equal('' , %x(cane --abc-glob "**/*.rb" --abc-max 15 --style-measure 80 --doc-glob "**/*.rb" --doc-exclude "test/**/*"))
    end
  end
end
