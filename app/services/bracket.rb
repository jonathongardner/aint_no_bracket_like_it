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
    reset_unique_games_available
    @games = value
    # so its unfroze
    binary_ugn = +''
    binary_pg  = +''
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

  def unique_games_available
    return @unique_games_available if @unique_games_available
    games_left = UniqueBracket.no_user
      .top_bracket_matches(top_games)
      .bottom_bracket_matches(bottom_games)

    top_games_left, bottom_games_left = games_left.pluck_top_and_bottom(@picked_games)
    # If there are no games available top_games_left and bottom_games_left will be nil so set to string
    unique = top_games_left.present? && bottom_games_left.present?
    top_games_left ||= ''
    bottom_games_left ||= ''


    @unique_games_available = (1..63).reduce('unique' => unique, 'finished' => finished?) do |acc, game_number|
      to_add = []
      to_add.push('top') if top_games_left[63 - game_number] == '1'
      to_add.push('bottom') if bottom_games_left[63 - game_number] == '1'
      acc.merge(game_number.to_s => to_add)
    end
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
    def reset_unique_games_available
      @unique_games_available = nil
    end
    def top_games
      @picked_games & ~@unique_game_number
    end
    def bottom_games
      @picked_games & @unique_game_number
    end

    def game_picked?(game_number)
      @binary_picked_games[63 - game_number] == '1'
    end
    def winner_of(game_number)
      @binary_unique_game_number[63 - game_number] == '0' ? 'top' : 'bottom'
    end

    def unique_game_number=(v)
      reset_unique_games_available
      @binary_unique_game_number = v.to_s(2).rjust(63, '0')
      @unique_game_number = v
    end
    def picked_games=(v)
      reset_unique_games_available
      @binary_picked_games = v.to_s(2).rjust(63, '0')
      @picked_games = v
    end

    def binary_unique_game_number=(v)
      reset_unique_games_available
      @unique_game_number = v.to_i(2)
      @binary_unique_game_number = v.rjust(63, '0')
    end
    def binary_picked_games=(v)
      reset_unique_games_available
      @picked_games = v.to_i(2)
      @binary_picked_games = v.rjust(63, '0')
    end
end
