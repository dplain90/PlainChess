require_relative './app'
require 'rack'
main = App.new

use Rack::Static, :urls => ["/assets/css", "/assets/images", "/assets/js"]
map '/' do
  run main.gameplay
end

map '/1p' do
  run main.player_game(1)
end

map '/2p' do
  run main.player_game(2)
end
