class UnitsController < ApplicationController
  SI_UNIT_CONVERSIONS = [
    {unit_regexp: /minute|min/, type: "time",        unit_name: "s",   multiplication_factor: 60.0 },
    {unit_regexp: /hour|h/,     type: "time",        unit_name: "s",   multiplication_factor: 3600.0 },
    {unit_regexp: /day|d/,      type: "time",        unit_name: "s",   multiplication_factor: 86400.0 },
    {unit_regexp: /degree|°/,   type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 180.0) },
    {unit_regexp: /‘/,          type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 10800.0) },
    {unit_regexp: /second|“/,   type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 648000.0) },
    {unit_regexp: /hectare|ha/, type: "area",        unit_name: "m²",  multiplication_factor: 10000.0 },
    {unit_regexp: /litre|L/,    type: "volume",      unit_name: "m³",  multiplication_factor: 0.001 },
    {unit_regexp: /tonne|t/,    type: "mass",        unit_name: "kg",  multiplication_factor: 1000.0 },
  ]
  SI_UNIT_CONVERSIONS_HASH = {
    "minute"  => { type: "time",        unit_name: "s",   multiplication_factor: 60.0 },
    "min"     => { type: "time",        unit_name: "s",   multiplication_factor: 60.0 },
    "hour"    => { type: "time",        unit_name: "s",   multiplication_factor: 3600.0 },
    "h"       => { type: "time",        unit_name: "s",   multiplication_factor: 3600.0 },
    "day"     => { type: "time",        unit_name: "s",   multiplication_factor: 86400.0 },
    "d"       => { type: "time",        unit_name: "s",   multiplication_factor: 86400.0 },
    "degree"  => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 180.0) },
    "°"       => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 180.0) },
    "‘"       => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 10800.0) },
    "second"  => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 648000.0) },
    "“"       => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 648000.0) },
    "hectare" => { type: "area",        unit_name: "m²",  multiplication_factor: 10000.0 },
    "ha"      => { type: "area",        unit_name: "m²",  multiplication_factor: 10000.0 },
    "litre"   => { type: "volume",      unit_name: "m³",  multiplication_factor: 0.001 },
    "L"       => { type: "volume",      unit_name: "m³",  multiplication_factor: 0.001 },
    "tonne"   => { type: "mass",        unit_name: "kg",  multiplication_factor: 1000.0 },
    "t"       => { type: "mass",        unit_name: "kg",  multiplication_factor: 1000.0 },
  }
  DELIMETERS = %r{([*/()])}
  
  MULTIPLY = Proc.new { |x, y|  x * y }
  DIVIDE   = Proc.new { |x, y|  x / y }

  def si
    units = params["units"]
   #tokens = units.split(%r{([*/()])}).reject(&:blank?)
    tokens = units.split(DELIMETERS).reject(&:blank?)

    puts "in units_controller#si params #{params}"
    puts "in units_controller#si units #{units}"
    puts "in units_controller#si tokens #{tokens}"
    
    @unit_name = ""
    @factor = 1
    next_operation = MULTIPLY
    
    tokens.each do |token|
      # TODO Watch for pluralized units
      conversion = SI_UNIT_CONVERSIONS_HASH[token]
      if conversion
        @factor = next_operation.call(@factor, conversion[:multiplication_factor])
        @unit_name += conversion[:unit_name]
      else # must be a delimeter
        case token
        when %r{[/]}
          next_operation = DIVIDE
        when %r{[*]}
          next_operation = MULTIPLY
    #   when %r{[(]}
    #     next_operation = open_group
    #   when %r{[)]}
    #     next_operation = close_group
        end
        @unit_name += token # TODO be Careful of gibberish input tokens
      end

    end


  # if units =~ /minute/
  #   @unit_name += "s"
  #   @factor *= 60.0
  # end
    @factor = @factor.round(14)
    render "units/si.json.jbuilder", unit_name: @unit_name, factor: @factor
  end


# def multiply(x, y)
#   x*y
# end

# def devide(x, y)
#   x/y
# end
end
