require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'pry'

set :sessions, true

BLACKJACK = 21
DEALER_STAY = 17
MONEY = 400


helpers do

  def calculate_total(cards)
    values = cards.map { |card| card[1] }

    total = 0

    values.each do |value|
      if value == "Ace"
        total += 11
      elsif value == "King" || value == "Queen" || value == "Jack"
        total += 10
      else
        total += value.to_i
      end
    end

    #correct for aces
    values.select{ |v| v == "Ace" }.count.times do
      total -= 10 if total > 21
    end

    total
    end

    def winner(msg)
      @winner = "#{msg}"
      session[:money] = session[:money] + session[:player_bet].to_i*2
      @show_hit_and_stay = false
    end

    def loser(msg)
      @loser = "#{msg}"
      @show_hit_and_stay = false
    end

    def tie(msg)
      @tie = "#{msg}"
      session[:money] = session[:money] + session[:player_bet].to_i
      @show_hit_and_stay = false
    end
end

before do
  @show_hit_and_stay = true
end

get '/' do
  if session[:player_name]
    redirect '/bet'
  else
    redirect '/name_form'
  end
end


get '/name_form' do
  session[:money] = MONEY
  erb :name_form
end


post '/name_form' do

  if params[:player_name].empty?
    @error = "You must enter a name."
    halt erb(:name_form)
  end

  session[:player_name] = params[:player_name]
  session[:player_name].capitalize!
  erb :bet
end


get '/bet' do
  session[:player_bet] = nil

  if session[:money] == 0
    @error = "You don't have any money left! Start a new game."
    halt erb(:bet)
  end
  erb :bet
end

post '/bet' do
  if params[:player_bet].empty? || params[:player_bet].to_i == 0
    @error = "You must bet something!"
    halt erb(:bet)
  elsif params[:player_bet].to_i > session[:money]
    @error = "You don't have that much money!"
    halt erb(:bet)
  else
    session[:player_bet] = params[:player_bet]
    session[:money] -= params[:player_bet].to_i
    redirect '/game'
  end

  if session[:money] == 0
    @error = "You don't have any money left! Start a new game."
    halt erb(:bet)
  end
end

get '/game' do
  session[:turn] = session[:player_name]

  #create deck
  suits = %w[hearts spades diamonds clubs]
  values = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace]
  session[:deck] = suits.product(values).shuffle!

  #deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  if calculate_total(session[:player_cards]) == BLACKJACK
    winner("You have blackjack! You win")
  end


  erb :game
end

post '/game/hit' do
    session[:player_cards] << session[:deck].pop
    player_total = calculate_total(session[:player_cards])

  if player_total > BLACKJACK
    loser("Sorry, you busted. You lose!")
  elsif player_total == BLACKJACK
    winner("Blackjack! You win")
  end

  erb :game
end

post '/game/stay' do
  @stay = "You have decided to stay with #{calculate_total(session[:player_cards])}."
  @show_hit_and_stay = false
  erb :game
end

post '/game/dealer' do
  redirect '/game/dealer'

end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_and_stay = false
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK
    loser("The dealer has blackjack! You lose!")
  elsif dealer_total > BLACKJACK
    winner("The dealer busted! You win!")
  elsif dealer_total >= DEALER_STAY
    redirect '/game/compare'
  else
    session[:dealer_cards] << session[:deck].pop
    redirect '/game/dealer'
  end

  erb :game
end

get '/game/compare' do
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total == dealer_total
    tie("It's a tie! Try again.")
  elsif player_total < dealer_total
    loser("You lose!")
  else
    winner("You win!")
  end
  erb :game
end



