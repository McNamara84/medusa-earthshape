require 'rest-client'

# modified datacite_doi_i_fy

module IgsnHelper
  VERSION = '0.0.4'
class Igsn
  ENDPOINT = 'https://doidb.wdc-terra.org/igsn'

  def initialize(opts = {})
    user=opts[:user]
    password=opts[:password]
    endpoint=opts[:endpoint]    
#    endpoint ||= ENDPOINT
    @endpoint = RestClient::Resource.new(endpoint, user, password)
  end

  def resolve(igsn)
    @endpoint["igsn/#{igsn}"].get
  end

  def mint(igsn, url)
    @endpoint['igsn'].post("igsn=#{igsn}\nurl=#{url}", content_type: 'text/plain;charset=UTF-8')
  end

  def upload_metadata(metadata)
    @endpoint['metadata/'].put(metadata, content_type: 'application/xml;charset=UTF-8')
  end

  def metadata(igsn)
    @endpoint["metadata/#{igsn}"].get
  end
end
end
