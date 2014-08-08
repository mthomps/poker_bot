get '/' do
  game_state = JSON.parse params[:game]
  pocket = JSON.parse params[:pocket]
  community_cards = game_state[:community]

  # parse gamestate
  # evaluate hand => confidence rating
  # take into account if using own cards or community cards
  # take position and # of players into account
  # determine action
end
