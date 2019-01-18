# frozen_string_literal: true

module BracketBinary
  extend ActiveSupport::Concern

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
