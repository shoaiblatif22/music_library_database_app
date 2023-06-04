require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
before(:each) do
  reset_albums_table
end

  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context 'GET /' do
    it 'returns the html index' do
      response = get('/')

      expect(response.body).to include('<h1>Hello!</h1>')
      expect(response.body).to include('<img src="hello.jpg"/>')
    end
  end

  context 'GET /albums ' do
    it 'should return the list of albums' do
      response = get('/albums')

      expected_response = 'Doolittle, Surfer Rosa, Waterloo, Super Trouper, Bossanova, Lover, Folklore, I Put a Spell on You, Baltimore, Here Comes the Sun, Fodder on My Wings, Ring Ring'

      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
    end
  end

  context 'POST /albums' do
    it 'should create a new album' do
      response = post('/albums', 
      title: 'Ok Computer', 
      release_year: '1997', 
      artist_id: '1')

      expect(response.status).to eq(200)
      expect(response.body).to eq('')

      response = get('/albums')

      expect(response.body).to include('Ok Computer') 
    end
  end

  context 'GET /artists' do
    it "should return a list of artists" do
      response = get("/artists")
      expected_response = "Pixies, ABBA, Taylor Swift, Nina Simone, Kiasmos"
      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
    end
  end

  context 'POST /artists' do
    it 'should create a new artist and return it in the response of GET /artists' do
      post('/artists', { name: 'Wild nothing', genre: 'Indie' })

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('')

      get('/artists')

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Wild nothing')
    end
  end
end
