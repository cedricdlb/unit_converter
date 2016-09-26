class UnitsController < ApplicationController
  SI_UNIT_CONVERSIONS = {
    "minute"  => { type: "time",        unit_name: "s",   multiplication_factor: 60.0 },
    "min"     => { type: "time",        unit_name: "s",   multiplication_factor: 60.0 },
    "hour"    => { type: "time",        unit_name: "s",   multiplication_factor: 3600.0 },
    "h"       => { type: "time",        unit_name: "s",   multiplication_factor: 3600.0 },
    "day"     => { type: "time",        unit_name: "s",   multiplication_factor: 86400.0 },
    "d"       => { type: "time",        unit_name: "s",   multiplication_factor: 86400.0 },
    "degree"  => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 180.0) },
    "°"       => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 180.0) }, # ° is Shift-Option 8 in vim, same as spec
    "˚"       => { type: "Plane angle", unit_name: "rad", multiplication_factor: (Math::PI / 180.0) }, # ˚ is Option k in vim, different from spec
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
  OPERATORS = %r{([*/()])}
  
  def si
    units = params["units"] || ""
    tokens = units.split(OPERATORS).reject(&:blank?).map(&:singularize)
    # Above, I reject blanks from split's returned array because
    # if there are two adjacent operators in the string,
    # split infers an empty string between them for the returned array,
    #puts "in units_controller#si tokens #{tokens}"

    @factor, @unit_name, @errors = collect_unit_names_and_factor(tokens)
    @factor = @factor.round(14)
    if @errors.empty?
      render "units/si.json.jbuilder", unit_name: @unit_name, factor: @factor
    else
      @errors << "Allowed operators are [(, ), *, /] Allowed units are: [#{SI_UNIT_CONVERSIONS.keys.join(", ")}]"
      render :json => { :errors => @errors }, :status => 400
    end
  end

  private
  def collect_unit_names_and_factor(tokens, unit_name = "", errors = [])  
    factor = 1.0
    multipy_or_divide_by = :*
    while(token = tokens.shift)
      conversion = SI_UNIT_CONVERSIONS[token]
      if conversion
        factor = factor.send(multipy_or_divide_by, conversion[:multiplication_factor])
        unit_name += conversion[:unit_name]
      else # must be an operator
        unit_name += token
        case token
        when /[*\/]/
          multipy_or_divide_by = token.to_sym
        when /[(]/
          sub_factor, unit_name, errors = collect_unit_names_and_factor(tokens, unit_name, errors)
          factor = factor.send(multipy_or_divide_by, sub_factor)
        when /[)]/
          return [factor, unit_name, errors]
        else
          errors << "Unrecognized token: #{token}."
        end
      end
    end
    return [factor, unit_name, errors]
  end

end
