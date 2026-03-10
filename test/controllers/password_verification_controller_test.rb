require "test_helper"

class PasswordVerificationControllerTest < ActionDispatch::IntegrationTest

  test "check returns score for valid password" do
    post "/password/check", params: { password: "StrongPass123!" }.to_json,
         headers: { "Content-Type" => "application/json" }

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "StrongPass123!", json["password"]
    assert json.key?("score")
    assert json.key?("crack_time")
    assert json.key?("crack_time_display")
    assert json.key?("feedback")
  end

  test "check returns error when password missing" do
    post "/password/check", params: {}.to_json, headers: { "Content-Type" => "application/json" }

    assert_response :bad_request
    json = JSON.parse(response.body)
    assert_equal "No password received", json["error"]
  end

  test "generate returns a password with default length" do
    get "/password/generate"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 16, json["password"].length
    assert json.key?("score")
  end

  test "generate respects length parameter" do
    get "/password/generate?length=20"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 20, json["password"].length
  end

  test "haveIbeenPwned returns pwned false for made-up password" do
    password = "TotallyUniquePassword2026!"

    # Mock the HTTP call
    stub_request(:get, /api.pwnedpasswords.com/).to_return(body: "")

    post "/password/haveibeenpwned", params: { password: password }.to_json,
         headers: { "Content-Type" => "application/json" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal password, json["password"]
    assert_equal false, json["pwned"]
    assert_equal 0, json["count"]
  end
end