#
#  test_gac.rb
#
#  Copyright (c) 2021 by Daniel Kelley
#
# frozen_string_literal: true

require 'yaml'
require 'test/unit'
require_relative '../lib/gac'

#
# GAC test cases
#
class TestU3S < Test::Unit::TestCase

  #
  # Make sure lib spec exists
  #
  def test_gac_001
    assert_not_nil GAC::Lib
  end

  #
  # Generate a panel with one of each GAC module
  #
  def test_gac_002
    modules = GAC::Lib.data.keys.reject { |k| k =~ /^[A-Z]+/ }
    spec = { 'blocks' => modules }
    spec_path = 'test_gac_002.yml'
    dsp_path = 'test_gac_002.dsp'
    file = File.new(spec_path, 'w')
    file.write(spec.to_yaml)
    file.close
    status = system("../bin/panel #{spec_path} > #{dsp_path}")
    assert(status)
    status = system("faust2jaqt -I ../lib -json -svg -osc #{dsp_path}")
    assert(status)
  end

  #
  # Generate a sine/output panel
  #
  def test_gac_003
    spec = { 'blocks' => [ 'sine', 'output' ] }
    spec_path = 'test_gac_003.yml'
    dsp_path = 'test_gac_003.dsp'
    file = File.new(spec_path, 'w')
    file.write(spec.to_yaml)
    file.close
    status = system("../bin/panel #{spec_path} > #{dsp_path}")
    assert(status)
    status = system("faust2jaqt -I ../lib -json -svg -osc #{dsp_path}")
    assert(status)
  end

end
