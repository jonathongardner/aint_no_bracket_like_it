# frozen_string_literal: true

module BracketBinary
  extend ActiveSupport::Concern

  NEXT_GAME = [
    33, 33, 34, 34, 35, 35, 36, 36, 37, 37, 38, 38, 39, 39, 40, 40, 41, 41,
    42, 42, 43, 43, 44, 44, 45, 45, 46, 46, 47, 47, 48, 48, 49, 49, 50, 50,
    51, 51, 52, 52, 53, 53, 54, 54, 55, 55, 56, 56, 57, 57, 58, 58, 59, 59,
    60, 60, 61, 61, 62, 62, 63, 63,
  ]

  # Save unique_game_number as binary of top seed beeting lower seed
  # Picked games is a binary of the games picked 1 is picked 0 is not
  def binary_unique_game_number
    self.unique_game_number.to_s(2).rjust(63, '0')
  end
  def binary_picked_games
    self.picked_games.to_s(2).rjust(63, '0')
  end
  def binary_unique_game_number=(v)
    self.unique_game_number = v.to_i(2)
  end
  def binary_picked_games=(v)
  end

  def top_seed_to_higher_seed_binary
    top_seed_binary = self.binary_unique_game_number
    higher_seed_binary = +''
    game_seeds = [
      [1, 64], [32, 33], [17, 48], [16, 49], [24, 41], [9, 56],
      [25, 40], [8, 57], [4, 61], [29, 36], [20, 45], [13, 52],
      [21, 44], [12, 53], [28, 37], [5, 60], [2, 63], [31, 34],
      [18, 47], [15, 50], [23, 42], [10, 55], [26, 39], [7, 58],
      [3, 62], [30, 35], [19, 46], [14, 51], [22, 43], [11, 54],
      [27, 38], [6, 59],
    ]
    (0..62).each do |game_number|
      winner_binary = top_seed_binary[62 - game_number].to_i
      winner_seed = game_seeds[game_number][winner_binary]
      loser_seed = game_seeds[game_number][1 - winner_binary]
      (game_seeds[BracketBinary::NEXT_GAME[game_number] - 1] ||= []).push(game_seeds[game_number][winner_binary]) if game_number != 62
      if winner_seed < loser_seed
        higher_seed_binary.prepend('0')
      else
        higher_seed_binary.prepend('1')
      end
    end

    higher_seed_binary.to_i(2)
  end

  def one_different_binary
    top_seed_binary = self.binary_unique_game_number
    to_return = []
    (0..62).each do |n|
      multiplier = (1 - 2 * (((self.unique_game_number / (2.0**n)).floor) % 2))
      to_return.push(self.unique_game_number + multiplier * (2**n))
    end
    to_return.sort!
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
    binary_ugn = self.binary_unique_game_number
    binary_pg = self.binary_picked_games
    @games = (1..63).reduce({}) do |acc, game_number|
      game_binary_position = 63 - game_number
      next acc if binary_pg[game_binary_position] == '0'
      acc.merge(game_number.to_s => {'winner' => binary_ugn[game_binary_position] == '0' ? 'top' : 'bottom'})
    end
  end
end
