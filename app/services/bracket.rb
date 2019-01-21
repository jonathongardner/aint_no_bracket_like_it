# frozen_string_literal: true

class Bracket
  FINISHED = 9223372036854775807
  attr_reader :unique_game_number, :picked_games, :binary_unique_game_number, :binary_picked_games
  # Save unique_game_number as binary of top seed beeting lower seed
  # Picked games is a binary of the games picked 1 is picked 0 is not
  def initialize(unique_game_number: 0, picked_games: 0, games: nil)
    if games
      self.games = games
    else
      self.unique_game_number = unique_game_number # this number wont matter since no games are picked
      self.picked_games = picked_games # 0 is no games picked
    end
  end

  def games=(value)
    @games = value
    binary_ugn = +''
    binary_pg = +'' # so its unfroze
    (1..63).each do |game_number|
      pt = @games.dig(game_number.to_s, 'winner')
      if pt == 'top'
        binary_ugn.prepend('0')
        binary_pg.prepend('1')
      elsif pt == 'bottom'
        binary_ugn.prepend('1')
        binary_pg.prepend('1')
      else
        binary_ugn.prepend('0') # this number wont matter since picked game will be 0 i.e. not picked
        binary_pg.prepend('0')
      end
    end
    self.binary_unique_game_number = binary_ugn
    self.binary_picked_games = binary_pg
  end

  def games
    return @games if @games
    @games = (1..63).reduce({}) do |acc, game_number|
      next acc unless game_picked?(game_number)
      acc.merge(game_number.to_s => {'winner' => winner_of(game_number)})
    end
  end
  def finished?
    @picked_games == Bracket::FINISHED # This is 111....111 in binary i.e. all picked
  end
  def missing_games
    missing_games = (1..63).reject { |g| game_picked?(g) }
  end

  private
    def game_picked?(game_number)
      @binary_picked_games[63 - game_number] == '1'
    end
    def winner_of(game_number)
      @binary_unique_game_number[63 - game_number] == '0' ? 'top' : 'bottom'
    end

    def unique_game_number=(v)
      @binary_unique_game_number = v.to_s(2).rjust(63, '0')
      @unique_game_number = v
    end
    def picked_games=(v)
      @binary_picked_games = v.to_s(2).rjust(63, '0')
      @picked_games = v
    end

    def binary_unique_game_number=(v)
      @unique_game_number = v.to_i(2)
      @binary_unique_game_number = v.rjust(63, '0')
    end
    def binary_picked_games=(v)
      @picked_games = v.to_i(2)
      @binary_picked_games = v.rjust(63, '0')
    end
end
