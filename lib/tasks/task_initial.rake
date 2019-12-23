require 'yaml'
require 'base64'
require 'faraday'
require 'json'
require 'spotify-client'

desc 'Initial data load'
task :task_initial => :environment do
    token = Token()

    $_config = {
      :access_token => token,
      :raise_error => true,
      :retries       => 0,    # automatically retry a certain number of times before returning
      :read_timeout  => 10,   # set longer read_timeout, default is 10 seconds
      :write_timeout => 10,   # set longer write_timeout, default is 10 seconds
      :persistent    => false # when true, make multiple requests calls using a single persistent connection. Use +close_connection+ method on the client to manually clean up sockets
    }

    #check the file yml

    artists_array = YAML.load(File.read('artists.yml'))

    artists_array['artists'].each {|item| ReadArtist(item) }


end
private
def Token

  client_id = 'd08d64371028481d8d595f38ebdc1581'
  client_secret = '6116300d14044075b42185c99b9f32b2'

  data_client = client_id + ':' + client_secret
  encode_data = 'Basic '  + Base64.encode64(data_client)

  url_token = 'https://accounts.spotify.com/api/token?grant_type=client_credentials'

  res = Faraday.post(url_token,URI.encode_www_form(
      grant_type:[:client_credentials]

  ),

                     {

                         "Content-Type" => "application/x-www-form-urlencoded",
                         "Accept" => "application/json",
                         "Authorization" => "Basic ZDA4ZDY0MzcxMDI4NDgxZDhkNTk1ZjM4ZWJkYzE1ODE6NjExNjMwMGQxNDA0NDA3NWI0MjE4NWM5OWI5ZjMyYjI="
                     }

  )

  if res.status == 200
    data = JSON[res.body]

    return data['access_token']
  else

    data = JSON[res.body]
    return data['error']

  end

end

private
  def ReadArtist (artist)

    client = Spotify::Client.new($_config)
    res = client.search('artist',artist)

    data = res["artists"]['items'][0]
    if data != nil
      data_geners =''
      cont =0
      if data['genres'].length > 0
        data['genres'].each{|item| data_geners= (cont == 0)? item : data_geners + ',' + item;  cont=cont+1 }
      end



      id_artist = res["artists"]['items'][0]['id']


      artist = Artist.create(:name => data['name'],:image => data['images'][0]['url'],:genres => data_geners,
                             :popularity => data['popularity'],:spotify_url => data['external_urls']['spotify'],:spotify_id =>data['id'] )

      

      ReadAlbums(artist)
    else
      puts 'No hay datos para cargar'
    end

  end

  private
  def ReadAlbums(artist)

    client = Spotify::Client.new($_config)
    res =  client.artist_albums(artist.spotify_id)

    res['items'].each {|item| AddAlbum(artist.id,item) }

  end

  private
  def AddAlbum (id_artist,album)

    @album = Album.create(name:album['name'],image:album['images'][0]['url'],spotify_url:album['external_urls']['spotify'],
                          total_tracks:album['total_tracks'],spotify_id:album['id'],artist_id:id_artist)

    ReadSongs(@album)

  end

  private
  def ReadSongs(album)
    client = Spotify::Client.new($_config)
    res = client.album_tracks(album.spotify_id)

    res['items'].each { |item| AddTrack(album.id,item) }

  end
  private
  def AddTrack(id_album,track)
    
    @track = Track.create(name:track['name'],spotify_url:track['external_urls']['spotify'],
    preview_url:track['preview_url'],duration_ms:track['duration_ms'],explicit:track['explicit'],
    spotify_id:track['id'],album_id:id_album)
    
    puts @track
    
  end