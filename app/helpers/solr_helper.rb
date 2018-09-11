require 'rest-client'

# modified datacite_doi_i_fy

module SolrHelper
  VERSION = '0.0.4'
class Solr
  ENDPOINT = 'http://doidb.wdc-terra.org/igsnaasearch/admin/dataimport?command=full-import&clean=false&commit=true&optimize=false&wt=json&indent=true'

  def initialize(opts = {})
    user=opts[:user]
    password=opts[:password]
    endpoint=opts[:endpoint]    
    endpoint ||=ENDPOINT
    @endpoint = RestClient::Resource.new(endpoint, user, password)
  end

  def deltaupdate()
    @endpoint.post('')
  end

  def update()
    @endpoint.post('')
  end

end
end
