require 'spec_helper'

describe ApplicationController do
  # Create a test controller to expose protected methods for testing
  controller do
    skip_before_action :authenticate_user!, raise: false
    
    def test_safe_referer
      render plain: safe_referer_url
    end

    def test_safe_referer_with_tab
      render plain: safe_referer_url_with_requested_tab
    end
  end

  describe '#safe_referer_url' do
    before do
      routes.draw do
        get 'test_safe_referer' => 'anonymous#test_safe_referer'
        get 'test_safe_referer_with_tab' => 'anonymous#test_safe_referer_with_tab'
      end
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
      it 'allows root-relative path (implicitly same-host)' do
        request.env['HTTP_REFERER'] = '/stones/123'
        get :test_safe_referer
        expect(response.body).to eq('/stones/123')
      end

      it 'rejects path-relative referers without a leading slash' do
        request.env['HTTP_REFERER'] = 'stones/123'
        get :test_safe_referer
        expect(response.body).to eq('/')
      end

      it 'allows root-relative path with query params' do
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

    context 'edge cases' do
      it 'handles protocol-relative URLs as different host' do
        request.env['HTTP_REFERER'] = '//other.host/path'
        get :test_safe_referer
        # Protocol-relative URLs have a host, so they should be rejected
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

  describe '#safe_referer_url_with_requested_tab' do
    before do
      routes.draw do
        get 'test_safe_referer' => 'anonymous#test_safe_referer'
        get 'test_safe_referer_with_tab' => 'anonymous#test_safe_referer_with_tab'
      end
    end

    it 'replaces an existing tab parameter that follows another query param' do
      request.env['HTTP_REFERER'] = '/stagings?view=import&tab=old'

      get :test_safe_referer_with_tab, params: { tab: 'boxes' }

      expect(response.body).to eq('/stagings?view=import&tab=boxes')
    end

    it 'falls back to root_path for malformed percent-encoding in the query string' do
      request.env['HTTP_REFERER'] = '/stagings?bad=%E0%A4%A'

      get :test_safe_referer_with_tab, params: { tab: 'boxes' }

      expect(response.body).to eq('/')
    end
  end

  describe '#basic_authentication' do
    let(:invalid_utf8) { "\xC2\x16".dup.force_encoding(Encoding::UTF_8) }
    let(:password) { 'secret' }

    around do |example|
      original_disable_http_basic = ENV['DISABLE_HTTP_BASIC']
      ENV.delete('DISABLE_HTTP_BASIC')
      example.run
    ensure
      if original_disable_http_basic.nil?
        ENV.delete('DISABLE_HTTP_BASIC')
      else
        ENV['DISABLE_HTTP_BASIC'] = original_disable_http_basic
      end
    end

    before do
      allow(controller).to receive(:authenticate_or_request_with_http_basic) do |&block|
        block.call(username, password)
      end
    end

    context 'when the user does not exist' do
      let(:username) { 'missing-user' }

      it 'rejects the credentials without raising an error' do
        expect(User).to receive(:find_by).with(username: username).and_return(nil)
        expect(controller).not_to receive(:sign_in)

        expect(controller.basic_authentication).to eq(false)
      end
    end

    context 'when the username contains invalid bytes' do
      let(:username) { invalid_utf8 }

      it 'rejects the credentials before hitting the database' do
        expect(User).not_to receive(:find_by)
        expect(controller).not_to receive(:sign_in)

        expect(controller.basic_authentication).to eq(false)
      end
    end

    context 'when the password contains invalid bytes' do
      let(:username) { 'valid-user' }
      let(:password) { invalid_utf8 }

      it 'rejects the credentials before hitting the database or password verification' do
        expect(User).not_to receive(:find_by)
        expect(controller).not_to receive(:sign_in)

        expect(controller.basic_authentication).to eq(false)
      end
    end

    context 'when the credentials are valid' do
      let(:username) { 'valid-user' }

      it 'looks up the user, verifies the password, and signs in' do
        resource = instance_double(User)

        expect(User).to receive(:find_by).with(username: username).and_return(resource)
        expect(resource).to receive(:valid_password?).with(password).and_return(true)
        expect(controller).to receive(:sign_in).with(:user, resource)

        expect(controller.basic_authentication).to eq(true)
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
        context "when tab is not the first query param" do
          let(:url){"#{base_url}?#{other_param}&#{other_tab_param}"}
          it { expect(subject).to eq "#{base_url}?#{other_param}&#{tab_param}"}
        end
        context "when the query string contains malformed percent encoding" do
          let(:url){"/stagings?bad=%E0%A4%A"}
          it { expect(subject).to eq "/"}
        end
      end
    end
  end

  describe '.record_path_for_global_id' do
    before do
      routes.draw do
        get 'records/by-global-id/*id/exact' => 'records#show', as: :record_by_global_id, format: false
        get 'records/by-global-id/*id/exact.:format' => 'records#show', as: :formatted_record_by_global_id, constraints: { format: /json|xml|pml|html/ }
      end
    end

    it 'always uses the exact global-id route for html lookups' do
      expect(@controller.record_path_for_global_id('folder/sample')).to eq('/records/by-global-id/folder/sample/exact')
    end

    it 'uses the formatted exact global-id route when a format is requested' do
      expect(@controller.record_path_for_global_id('sample.id.v1.json', format: :json)).to eq('/records/by-global-id/sample.id.v1.json/exact.json')
    end
  end
end
