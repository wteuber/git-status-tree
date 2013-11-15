# encoding: utf-8
require 'bundler/setup'

class TestCodeQuality < Test::Unit::TestCase

  def test_cane
    if ENV['RUBY_VERSION'][0..9] >= 'ruby-1.9.0'
      options = {
        '--abc-glob'      => '"{bin,lib,src,test}/**/*.rb"',
        '--abc-max'       => '15',
        '--style-measure' => '80',
        '--doc-glob'      => '"{bin,lib,src}/**/*.rb"',
        '--doc-exclude'   => '"{test,vendor}/**/*"'
      }
      assert_equal('' , %x(cane #{options.to_a * ' '}))
    end
  end
end
