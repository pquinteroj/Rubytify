module Api
    module V1 
        class ArtistsController < ApplicationController
            def index
                res = Artist.order('created_at DESC')

                artists= Array.new
                if res.length > 0
                    res.each { |item| artists.push(addArtist(item)) }
                end
                render json: {status:'SUCCESS',message:'Load Artists',data:artists},status: :ok
            end
            def albums
                res = Album.where(artist_id: params[:id])

                albums = Array.new
                if res.length > 0
                    res.each { |item| albums.push(addAlbum(item)) }
                end

                render json: {status:'SUCCESS',message:'Load Albums',data:albums},status: :ok
            end

            
            private
            def addArtist(artist)
                genres = artist.genres.split(',')
                data = {
                    id:artist.id,
                    name:artist.name,
                    image:artist.image,
                    genres:genres,
                    popularity:artist.popularity,
                    spotify_url:artist.spotify_url
                }



            end

            private 
            def addAlbum(album)
                return data={
                    id:album.id,
                    name:album.name,
                    image:album.image,
                    spotify_url:album.spotify_url,
                    total_tracks:album.total_tracks
                }
            end 
        end
    end
end