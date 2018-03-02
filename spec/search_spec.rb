require_relative 'spec_helper'


describe 'Search' do


  before(:all) do
    RSpec.configure { |c| c.include RSpecMixin }
    configure_empty_sqlite
    SystematicReview.insert(:name=>'Test Review', :group_id=>1, :sr_administrator=>1)
    login_admin
  end

  def filepath
    filename="manual.bib"
    File.expand_path("#{File.dirname(__FILE__)}/../docs/guide_resources/#{filename}")
  end
  let(:search) {Search[1]}
  let(:filesize) {File.size(filepath)}
  let(:sr_id) {sr_by_name_id('Test Review')}
  let(:bb_id) {bb_by_name_id('generic')}

  # Just some preliminary checks. Don't load the rest of suite if this fails

  context 'when check initial state' do
    it "should be 0 searches" do
        expect(Search.count).to eq(0)
    end
    it "should be 0 records" do
      expect(Record.count).to eq(0)
    end
    it "should be 0 references" do
      expect(Reference.count).to eq(0)
    end

  end
  context 'when create a search by form' do
    before(:context) do
      uploaded_file=Rack::Test::UploadedFile.new(filepath, "text/x-bibtex",true)
      post '/search/update', {search_id:'', file:uploaded_file, systematic_review_id: sr_by_name_id('Test Review') , bibliographic_database_id:bb_by_name_id('generic'), source:'informal_search', date_creation:'2018-01-01'}
    end

    it "response should be redirect" do
      expect(last_response).to be_redirect
    end
    it "should response redirects to review's searches" do
      expect(last_response.header['Location']).to eq("http://example.org/review/#{sr_id}/searches")
    end
    it "should search be created on dataset" do
      expect(search).to be_truthy
    end
    it "should search contains correct file name" do
      expect(search[:filename]).to eq('manual.bib')
    end
    it "should search bibliographic database will be generic" do
      expect(search[:bibliographic_database_id]).to eq(bb_id)
    end
    it "should search date will be 2018-01-01" do
      expect(search[:date_creation]).to eq(Date.new(2018,01,01))
    end

    # Remember that sqlite sends to ruby a ASCII-8BIT
    it "should search contains correct file content" do
=begin
      File.read(filepath)=~/^(.+In this way, considerable parts of the review's.+)$/
      content_file= $1

      search_o[:file_body]=~/^(.+In this way, considerable parts of the review's.+)$/
      content_object= $1

      $log.info(content_file)
      $log.info(content_object)
      $log.info(content_file.encoding)
      $log.info(content_object.encoding)
      $log.info(content_file==content_object)
=end
      expect(search[:file_body].force_encoding('UTF-8')).to eq(File.read(filepath))
    end
  end
  context "when review searches is accesed" do
    let(:response) {get "/review/#{sr_by_name_id('Test Review')}/searches"}
    it { expect(response).to be_ok}
    it "should include a row for new search" do
      expect(response.body).to include("id='row-search-1'")
    end

  end
  context "when search view is acceded" do
    let(:response) {get '/search/1'}
    it { expect(response).to be_ok}
    it "should include the bibliographic database name " do
      expect(response.body).to include("generic")
    end
    it "should include a link to file" do
      expect(response.body).to include("/search/1/file/download")
    end
  end

  context "when edit form search is acceded" do
    let(:response) {get '/search/1/edit'}
    it { expect(response).to be_ok}
    it "should include the bibliographic database name " do
      expect(response.body).to include("generic")
    end
    it "should include a link to file" do
      expect(response.body).to include("/search/1/file/download")
    end
  end



  context "when search file is downloaded" do
    let(:response) {get '/search/1/file/download'}

    it { expect(response).to be_ok}
    it "should response be ok" do expect(last_response).to be_ok end
    it "should content type be text/x-bibtex" do expect(last_response.header['Content-Type']).to include('text/x-bibtex') end
    it "should content length be correct" do expect(last_response.header['Content-Length']).to eq(filesize.to_s) end
    it "should filename will be correct" do expect(last_response.header['Content-Disposition']).to eq('attachment; filename=manual.bib') end
  end

  context 'when process the search using batch form' do
    before(:context) do
      searches_id=[1]
      post '/searches/update_batch', {search:1,searches:searches_id, action:'process', url_back:'URL_BACK'}
    end
    it "response should be redirect" do
      #$log.info(last_response)
      expect(last_response).to be_redirect
    end
    it "should response redirects to 'url_back' param" do
      expect(last_response.header['Location']).to eq("http://example.org/URL_BACK")
    end
  end
  if(true)
    context "records when search is already processed" do

      let(:expected_titles) do
        [
            "SLuRp : A Tool to Help Large Complex Systematic Literature Reviews Deliver Valid and Rigorous Results",
            "SWIFT-Review: A text-mining workbench for systematic review",
            "ExaCT: automatic extraction of clinical trial characteristics from journal publications",
            "RevManHAL: Towards automatic text generation in systematic reviews",
            "GAPscreener: An automatic tool for screening human genetic association literature in PubMed using the support vector machine technique",
            "Effectiveness and efficiency of search methods in systematic reviews of complex evidence: Audit of primary sources"
        ].sort
      end
      before(:context) do
        searches_id=[1]
        post '/searches/update_batch', {search:1,searches:searches_id, action:'process', url_back:'URL_BACK'}
      end
      let(:records) {Search[1].records_dataset }
      it "should be 6" do
        expect(records.count).to eq(6)
      end
      it "should have correct titles " do
        actual_titles=records.map(:title).sort
        expect(actual_titles).to eq(expected_titles)
      end
      it "should have correct bibliographic db assigned" do
        expect(records.map(:bibliographic_database_id).uniq).to eq([bb_id])
      end
      context "and records view is accesed" do
        before(:context) do
          get '/search/1/records'
        end
        it {expect(last_response).to be_ok}
        it "should contain all titles" do
          expected_titles.each do |title|
            expect(last_response.body).to include title
          end
        end
      end

    end
    context 'when validate the search with direct link' do
      before(:context) do
        get '/search/1/validate'
      end
      it "response should be redirect" do
        expect(last_response).to be_redirect
      end
      it "search should be validadet" do
        expect(search[:valid]).to be true
      end
    end

    context 'when invalidate the search with direct link' do
      before(:context) do
        get '/search/1/invalidate'
      end
      it "response should be redirect" do
        expect(last_response).to be_redirect
      end
      it "search should be invalidated" do
        expect(search[:valid]).to be false
      end
    end
    end
  end


