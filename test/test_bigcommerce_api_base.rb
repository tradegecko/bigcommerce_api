require 'helper'

class BigcommerceAPI::BaseTest < Minitest::Test
  def test_hello_world
    stub_request(:get, "https://api.bigcommerce.com/stores/ABC/v2/time").to_return(body: '{"time":"ABC"}')
    stub_request(:get, "https://api.bigcommerce.com/stores/DEF/v2/time").to_return(body: '{"time":"DEF"}')

    session = BigcommerceAPI::Base.new(store_hash: "ABC", client_id: "ABC", access_token: "ABC")

    Thread.new do
      session2 = BigcommerceAPI::Base.new(store_hash: "DEF", client_id: "DEF", access_token: "DEF")
      assert_equal("DEF", session2.time)
    end.join

    assert_equal("ABC", session.time)
    assert_requested(:get, "https://api.bigcommerce.com/stores/ABC/v2/time", headers: {'X-Auth-Client'=>'ABC', 'X-Auth-Token'=>'ABC'})
  end
end
