require 'test_helper'

class UnitsControllerTest < ActionController::TestCase
   test "should get si" do
     get :si
     assert_response :success
   end
    
 #test "should get si with params minute and return s and factor" do
  test "minute" do
    get :si, format: :json, units: "minute"
    json = JSON.parse(response.body)
    assert_equal({ "unit_name" => "s", "multiplication_factor" => "60.0" }, json, 
                 'Unexpected value for json (Expected { "unit_name" => "s", "multiplication_factor" => "60.0" })')
  end

  # Here is an example input and output for “degrees/minute”:
  # GET "/units/si?units=degrees/minute"
  # ­>
  # { "unit_name": "rad/s", "multiplication_factor": "0.00029088820867" }
  test "degree_minute" do
    get :si, format: :json, units: "degree/minute"
    json = JSON.parse(response.body)
    assert_equal({ "unit_name" => "rad/s", "multiplication_factor" => "0.00029088820867" }, json,
                 'Unexpected value for json (Expected { "unit_name" => "rad/s", "multiplication_factor" => "0.00029088820867" })')
  end
 
  test "degrees_minute_tonne" do
    get :si, format: :json, units: "(degrees*minute)/(tonne)"
    json = JSON.parse(response.body)
    assert_equal({ "unit_name" => "(rad*s)/(kg)", "multiplication_factor" => "0.0010471975512" }, json,
                 'Unexpected value for json (Expected { "unit_name" => "(rad*s)/(kg)", "multiplication_factor" => "0.0010471975512" })')
  end
 
  test "its_a_complicated_one" do
    get :si, format: :json, units: "(minutes/min)*(hs/hour)*(days/d)*(°/˚)*(°/degrees)*(‘/‘)*(“/second)*(ha/hectare)*(litre/L)*(t/tonnes)"
    json = JSON.parse(response.body)
    assert_equal({ "unit_name" => "(s/s)*(s/s)*(s/s)*(rad/rad)*(rad/rad)*(rad/rad)*(rad/rad)*(m²/m²)*(m³/m³)*(kg/kg)", "multiplication_factor" => "1.0" }, json,
                 'Unexpected value for json (Expected all factors to cancel out to 1.0)')
  end
 
  test "errored_input" do
    get :si, format: :json, units: "(degrees*minute/cats)/(tonne*dogs)"
    json = JSON.parse(response.body)
    assert_response(:bad_request, "Expected an client error status code 400, Bad Request")
    assert_includes( json["errors"], "Unrecognized token: dog.", "Expected an error about a bad dog" )
    assert_includes( json["errors"], "Unrecognized token: cat.", "Expected an error about a bad cat" )
    allowed = 'Allowed operators are [(, ), *, /] Allowed units are: [minute, min, hour, h, day, d, degree, °, ˚, ‘, second, “, hectare, ha, litre, L, tonne, t]'
    assert_includes( json["errors"], allowed, "Expected errors to indicate allowed inputs" )
  end
end
