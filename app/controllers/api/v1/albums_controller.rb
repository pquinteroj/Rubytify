module Api
    module V1
        class AlbumsController < ApplicationController
            def songs
                res = Track.where(album_id:params[:id])
                tracks=Array.new
                if res.length > 0
                    res.each { |item| tracks.push(add(item))  }
                end

                render json: {status:'SUCCESS',message:'Load Artists',data:tracks},status: :ok

            end

            private
            def add(track)
                return data = {
                    name:track.name,
                    spotify_url:track.spotify_url,
                    preview_url:track.preview_url,
                    duration_ms:track.duration_ms,
                    explicit:track.explicit
                }
            end
        end
    end
end