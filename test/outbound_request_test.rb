class OutboundRequestTest < ActiveSupport::TestCase
  setup do
    OutboundRequest.delete_all
    OutboundRequest.create! service: 'SRV1', action: 'ACT-A', response_code: '200'
    OutboundRequest.create! service: 'SRV1', action: 'ACT-B', response_code: '200'
    OutboundRequest.create! service: 'SRV1', action: 'ACT-C', response_code: '200'
    OutboundRequest.create! service: 'SRV2', action: 'ACT-D', response_code: '404'

    req = OutboundRequest.new service: 'SRV2', action: 'ACT-E', response_code: '404'
    req.created_at = 4.minutes.ago
    req.save!
  end

  test '#rpm should select the requests within the last minute' do
    assert_equal 4, OutboundRequest.rpm
  end

  test '#rpm should select only 200 responses' do
    assert_equal 3, OutboundRequest.rpm(response_code: '200')
  end

  test '#rpm should select only SRV1 requests' do
    assert_equal 3, OutboundRequest.rpm(service: 'SRV1')
  end

  test '#rpm should select only ACT-A requests' do
    assert_equal 1, OutboundRequest.rpm(action: 'ACT-A')
  end

  test '#rpm should select only ACT-E requests, which should be 0 due to time limit' do
    assert_equal 0, OutboundRequest.rpm(action: 'ACT-E')
  end

  test '#rpm should select only SRV2 requests, over a 2 minute period' do
    assert_equal 0.5, OutboundRequest.rpm(service: 'SRV2', period: 2.minutes)
  end

  test '#rpm should select only SRV2 requests, over a 10 minute period' do
    assert_equal 0.2, OutboundRequest.rpm(service: 'SRV2', period: 10.minutes)
  end
end