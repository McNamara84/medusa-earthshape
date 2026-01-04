require 'spec_helper'

describe ApplicationController do
  # Create a test controller to expose protected methods for testing
  controller do
    skip_before_action :authenticate_user!, raise: false
    
    def test_safe_referer
      render plain: safe_referer_url
    end
  end

  describe '#safe_referer_url' do
    before do
      routes.draw { get 'test_safe_referer' => 'anonymous#test_safe_referer' }
    end

    context 'when referer is blank' do
      it 'returns root_path for nil referer' do
        request.env['HTTP_REFERER'] = nil
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'returns root_path for empty string referer' do
        request.env['HTTP_REFERER'] = ''
        get :test_safe_referer
        expect(response.body).to eq('/')
      end
    end

    context 'when referer is from the same host' do
      it 'allows same-host absolute URL' do
        request.env['HTTP_REFERER'] = 'http://test.host/stones/123'
        get :test_safe_referer
        expect(response.body).to eq('http://test.host/stones/123')
      end

      it 'allows same-host URL with query params' do
        request.env['HTTP_REFERER'] = 'http://test.host/stones?page=2&tab=info'
        get :test_safe_referer
        expect(response.body).to eq('http://test.host/stones?page=2&tab=info')
      end
    end

    context 'when referer is from a different host' do
      it 'returns root_path for different domain' do
        request.env['HTTP_REFERER'] = 'http://evil.com/phishing'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'returns root_path for subdomain mismatch' do
        request.env['HTTP_REFERER'] = 'http://subdomain.test.host/path'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end
    end

    context 'when referer is a relative URL' do
      it 'allows relative path (implicitly same-host)' do
        request.env['HTTP_REFERER'] = '/stones/123'
        get :test_safe_referer
        expect(response.body).to eq('/stones/123')
      end

      it 'normalizes relative path without leading slash' do
        request.env['HTTP_REFERER'] = 'stones/123'
        get :test_safe_referer
        expect(response.body).to eq('/stones/123')
      end

      it 'allows relative path with query params' do
        request.env['HTTP_REFERER'] = '/stones?tab=info'
        get :test_safe_referer
        expect(response.body).to eq('/stones?tab=info')
      end
    end

    context 'when referer is an invalid URI' do
      it 'returns root_path for malformed URL' do
        request.env['HTTP_REFERER'] = 'http://[invalid'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end
    end

    context 'when referer uses a dangerous or unsupported scheme' do
      it 'rejects javascript: URLs' do
        request.env['HTTP_REFERER'] = 'javascript:alert(1)'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'rejects data: URLs' do
        request.env['HTTP_REFERER'] = 'data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=='
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'rejects file: URLs' do
        request.env['HTTP_REFERER'] = 'file:///etc/passwd'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'rejects other non-http/https schemes' do
        request.env['HTTP_REFERER'] = 'ftp://test.host/path'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end
    end

    context 'edge cases' do
      it 'handles protocol-relative URLs as different host' do
        request.env['HTTP_REFERER'] = '//other.host/path'
        get :test_safe_referer
        # Protocol-relative URLs have a host, so they should be rejected
        expect(response.body).to eq('/')
      end

      it 'rejects protocol-relative URLs even without a scheme' do
        request.env['HTTP_REFERER'] = '//evil.com/path'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'rejects relative-looking paths starting with // (host nil branch)' do
        # Ruby parses "////..." as host=nil with a path starting with "//".
        request.env['HTTP_REFERER'] = '////evil.com/path'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'allows URLs with fragments' do
        request.env['HTTP_REFERER'] = 'http://test.host/stones/123#details'
        get :test_safe_referer
        expect(response.body).to eq('http://test.host/stones/123#details')
      end

      it 'allows URLs with encoded characters in path' do
        request.env['HTTP_REFERER'] = 'http://test.host/stones/my%20stone'
        get :test_safe_referer
        expect(response.body).to eq('http://test.host/stones/my%20stone')
      end
    end

    context 'port mismatch (different service protection)' do
      it 'returns root_path when referer port differs from request port' do
        # Simulates redirect to different service on same host
        request.env['HTTP_REFERER'] = 'http://test.host:8080/path'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'returns root_path for non-standard port when request is on default port' do
        request.env['HTTP_REFERER'] = 'http://test.host:3000/stones'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end
    end

    context 'scheme mismatch (protocol downgrade protection)' do
      it 'returns root_path when referer is https but request is http' do
        # Prevents protocol downgrade attack
        request.env['HTTP_REFERER'] = 'https://test.host/secure/path'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'returns root_path when schemes differ (http vs https)' do
        request.env['HTTP_REFERER'] = 'https://test.host/stones/123'
        get :test_safe_referer
        # Request is http://test.host, referer is https://test.host
        expect(response.body).to eq('/')
      end
    end
  end

  describe ".adjust_url_by_requesting_tab" do
    subject{ @controller.adjust_url_by_requesting_tab(url) }
    let(:tabname){"analysis"}
    let(:base_url){"http://wwww.test.co.jp/"}
    let(:tab_param){"tab=#{tabname}"}
    let(:other_param){"aaa=aaa"}
    let(:other_tab_param){"tab=aaa"}
    before{@controller.params[:tab] = tab}
    context "none tab param" do
      let(:tab){""}
      let(:url){base_url}
      it { expect(subject).to eq base_url}
    end
    context "present tab param" do
      let(:tab){tabname}
      context "none tab param in url" do
        context "none other param in url" do
          let(:url){base_url}
          it { expect(subject).to eq "#{base_url}?#{tab_param}"}
        end
        context "present other param in url" do
          let(:url){"#{base_url}?#{other_param}"}
          it { expect(subject).to eq "#{base_url}?#{other_param}&#{tab_param}"}
        end
      end
      context "present tab param in url" do
        context "none other param in url" do
          let(:url){"#{base_url}?#{other_tab_param}"}
          it { expect(subject).to eq "#{base_url}?#{tab_param}"}
        end
        context "present other param in url" do
          let(:url){"#{base_url}?#{other_tab_param}&#{other_param}"}
          it { expect(subject).to eq "#{base_url}?#{other_param}&#{tab_param}"}
        end
      end
    end
  end
end
