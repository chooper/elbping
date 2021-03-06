require 'test/unit'
require 'elbping/pinger.rb'

DEFAULT_NODE    = ENV['TEST_NODE']     || '127.0.0.1'
DEFAULT_HOST    = ENV['TEST_HOST']     || 'localhost'
DEFAULT_PORT    = ENV['TEST_PORT']     || '80'
DEFAULT_PATH    = ENV['TEST_PATH']     || '/'
DEFAULT_SSL     = ENV['TEST_SSL']      || false
DEFAULT_VERBLEN = ENV['TEST_VERBLEN']  || 128
DEFAULT_TIMEOUT = ENV['TEST_TIMEOUT']  || 3

class TestHttpPinger < Test::Unit::TestCase
  def test_ping_node
    # ping_node(node, port, path, use_ssl, verb_len, timeout)
    # -> hash
    resp = nil
    assert_nothing_raised do
      resp = ElbPing::HttpPinger.ping_node(
        DEFAULT_NODE,
        DEFAULT_HOST,
        DEFAULT_PORT,
        DEFAULT_PATH,
        DEFAULT_SSL,
        DEFAULT_VERBLEN,
        DEFAULT_TIMEOUT)
    end
    #  {:code => error |||| response.code,
    #    :exception => exc,
    #    :node => node,
    #    :duration => ((Time.now.getutc - start) * 1000).to_i} # returns in ms
    assert_equal resp.class, Hash
    assert_equal resp[:node], DEFAULT_NODE
    assert_equal resp[:duration].class, Fixnum
    assert_not_equal resp[:code], nil
  end
end

require 'openssl'
class TestCertMatches
  def test_wildcard
    cert = OpenSSL::X509::Certificate.new
    cert.subject = OpenSSL::X509::Name.parse "/CN=*.example.com"

    assert ElbPing::HttpPinger.cert_matches?(cert, "www.example.com")
    assert_false ElbPing::HttpPinger.cert_matches?(cert, "www.example.org")
  end

  def test_static
    cert = OpenSSL::X509::Certificate.new
    cert.subject = OpenSSL::X509::Name.parse "/CN=www.example.com"

    assert ElbPing::HttpPinger.cert_matches?(cert, "www.example.com")
    assert_false ElbPing::HttpPinger.cert_matches?(cert, "www.example.org")
  end
end

