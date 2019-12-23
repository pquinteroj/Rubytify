module Api
    module V1
        class GenresController < ApplicationController
            
            $_data = Array.new

            def index
                $_data= Array.new
                search = params[:genre_name]
                artists = Artist.all
                if artists.length > 0
                    artists.each {|item| genres(search,item)}
                    render json: {status:'SUCCESS',message:'Load Artists',data:$_data},status: :ok 
                    
                end
            end

            #Consulto los Generos y valido que artita lo tiene
            private 
            def genres(search,artist)
        
                data_genres = artist['genres'].split(',')
                
                data_genres.each {|item| validarData(search,item,artist.id) }

            end 

            private
            def validarData(search,item,id_artist)
                if search.strip.upcase == item.strip.upcase
                   album(id_artist)
                end
            end

            #Consuloto los Albunes del Genero
            private 
            def album(id)
                albums = Album.where(artist_id:id)
                if albums.length > 0
                    albums.each {|item| track(item.id) }
                end
            end

            #Consuloto las Canciones del Genero
            private 
            def track(id)
                tracks = Track.where(album_id:id)
                
                if tracks.length > 0
                    tracks.each {|item| addTrack(item)}
                end

            end

            #Carga las canciones en la variable 
            private
            def addTrack(item)
                track = {
                    name:item.name,
                    spotify_url:item.spotify_url,
                    preview_url:item.preview_url,
                    duration_ms:item.duration_ms,
                    explicit:item.explicit                   
                }

                $_data.push(track)

            end
        end
    end
end