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
class TestGAC < Test::Unit::TestCase
  #
  # Builders
  #
  def gac_build(name, spec)
    spec_path = "#{name}.yml"
    dsp_path = "#{name}.dsp"
    file = File.new(spec_path, 'w')
    file.write(spec.to_yaml)
    file.close
    status = system("../bin/panel #{spec_path} > #{dsp_path}")
    assert(status)
    status = system("faust2jaqt -me -I ../lib -json -svg -osc #{dsp_path}")
    assert(status)
    status = system("faust -me -lang c -I ../lib/ -a faust/architecture/testdvr.c #{dsp_path} > #{name}_driver.c")
    assert(status)
    status = system("make #{name}_driver")
    assert(status)
    status = system("./#{name}_driver -n 1000000")
    assert(status)
  end

  def gac_jack(name, spec)
    dsp_path = "#{name}.dsp"
    spec_path = "#{name}.yml"
    file = File.new(spec_path, 'w')
    file.write(spec.to_yaml)
    file.close
    status = system("../bin/panel #{spec_path} > #{dsp_path}")
    assert(status)
    status = system("faust2jaqt -me -I ../lib -json -svg -osc #{dsp_path}")
    assert(status)
  end

  def gac_modules
    GAC::Lib.data.keys.reject { |k| k =~ /^[A-Z]+/ }
  end

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
    spec = { 'blocks' => gac_modules }
    gac_build('test_gac_002', spec)
  end

  #
  # Generate a sine/output panel
  #
  def test_gac_003
    spec = { 'blocks' => %w[sine output] }
    gac_jack('test_gac_003', spec)
  end

  #
  # Generate a noise/noise/output panel
  #
  def test_gac_004
    spec = { 'blocks' => %w[noise noise output] }
    gac_jack('test_gac_004', spec)
  end
end
