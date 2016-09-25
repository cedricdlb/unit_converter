require 'test_helper'

class UnitsControllerTest < ActionController::TestCase
#  test "should get si" do
#    get :si
#    assert_response :success
#  end
    
#  test "should get si with params foo" do
#    get :si
#    json = JSON.parse(response.body)
#    assert_equal("bar", json["foo"], "Unexpected value for json['foo'] (Expected bar)")
#  end

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
 
 #test "should get si with params minute and return s and factor" do
  test "minute" do
    get :si, format: :json, units: "minute"
    json = JSON.parse(response.body)
    assert_equal({ "unit_name" => "s", "multiplication_factor" => "60.0" }, json, 
                 "Unexpected value for json (Expected { \"unit_name\" => \"s\", \"multiplication_factor\" => \"60.0\" })")
  end
 

end
