require 'rest-client'

# modified datacite_doi_i_fy

module IgsnHelper
  VERSION = '0.0.4'
class Igsn
  ENDPOINT = 'https://doidb.wdc-terra.org/igsnaa'

  def initialize(opts = {})
    user=opts[:user]
    password=opts[:password]
    endpoint=opts[:endpoint]    
#    endpoint ||= ENDPOINT
    @endpoint = RestClient::Resource.new(endpoint, user, password)
  end

  def resolve(igsn)
    suffix="igsn/10273/#{igsn}"
    @endpoint["igsn/10273/#{igsn}"].get
  end

  def mint(igsn, url)
    @endpoint["igsn"].post("igsn=10273/#{igsn}\nurl=#{url}", content_type: 'text/plain;charset=UTF-8')
  end

  def upload_regmetadata(metadata)
    @endpoint["metadata"].post(metadata, content_type: 'application/xml;charset=UTF-8')
  end

  def upload_metadata(igsn,metadata)
    @endpoint["igsnmetadata/10273/#{igsn}"].post(metadata, content_type: 'application/xml;charset=UTF-8')
  end

  def metadata(igsn)
    @endpoint["metadata/10273/#{igsn}"].get
  end
end
end
