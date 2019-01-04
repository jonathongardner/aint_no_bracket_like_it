teams = File.open(File.join(Rails.root, 'db', 'seeds', 'teams.csv')).map do |line|
   team = line.gsub!("\n", '').split(',')[0..3]
   [team[0], team[1], team[1][0..15], team[2], team[3]]
end

tournament_teams = []
tournament_match_ups = []
tt_id = 1
team_id_to_tournament_team = {}
File.open(File.join(Rails.root, 'db', 'seeds', 'games.csv')).each_with_index do |line, tmu_id|
  # game#, year, region, top_team_id, top_team_seed, top_team_points, bottom_team_id, bottom_team_seed, bottom_team_points, round_of
  game = line.gsub!("\n", '').split(',')
  year = game[1]
  if game[9] == "64"
    team_id_to_tournament_team[year] ||= {}
    tournament_teams.push([tt_id, year, game[3], game[4]])
    team_id_to_tournament_team[year][game[3]] = tt_id
    tt_id += 1
    tournament_teams.push([tt_id, year, game[6], game[7]])
    team_id_to_tournament_team[year][game[6]] = tt_id
    tt_id += 1
  end
  tournament_match_ups.push([
    tmu_id, game[0], team_id_to_tournament_team[year][game[3]], game[5], team_id_to_tournament_team[year][game[6]], game[8]
  ])
end

if Rails.env.test?
  # Create a yaml file with 2017 tournament in it
  tournament_teams.delete_if {|tt| tt[1] != '2017'}
  team_ids = tournament_teams.map(&:third)
  tournament_team_ids = tournament_teams.map(&:first)
  teams.delete_if {|t| !team_ids.include?(t[0])}
  tournament_match_ups.delete_if {|tmu| !tournament_team_ids.include?(tmu[2])}

  team_id_to_fixture_base_name = {}
  File.open(File.join(Rails.root, 'db', 'fixtures', 'teams.yml'), 'w') do |w|
    teams.each do |team|
      fixture_base_name = team[1].gsub(' ', '').underscore
      team_id_to_fixture_base_name[team[0]] = fixture_base_name
      w.puts "#{fixture_base_name}_team:"
      w.puts "  name: #{team[1]}"
      w.puts "  short_name: #{team[2]}"
      w.puts "  city: #{team[3]}"
      w.puts "  state: #{team[4]}"
    end
  end

  tournament_team_id_to_fixture_base_name = {}
  File.open(File.join(Rails.root, 'db', 'fixtures', 'tournament_teams.yml'), 'w') do |w|
    tournament_teams.each do |tournament_team|
      fixture_base_name = team_id_to_fixture_base_name[tournament_team[2]]
      tournament_team_id_to_fixture_base_name[tournament_team[0]] = fixture_base_name
      w.puts "#{fixture_base_name}_tournament_team:"
      w.puts "  year: #{tournament_team[1]}"
      w.puts "  team: #{fixture_base_name}_team"
      w.puts "  rank: #{tournament_team[3]}"
    end
  end

  File.open(File.join(Rails.root, 'db', 'fixtures', 'tournament_match_ups.yml'), 'w') do |w|
    tournament_match_ups.each do |tournament_match_up|
      top_fixture_base_name = tournament_team_id_to_fixture_base_name[tournament_match_up[2]]
      bottom_fixture_base_name = tournament_team_id_to_fixture_base_name[tournament_match_up[4]]
      fixture_base_name = "#{top_fixture_base_name}_#{bottom_fixture_base_name}"
      w.puts "#{fixture_base_name}_tournament_match_up:"
      w.puts "  game: #{tournament_match_up[1]}"
      w.puts "  top_tournament_team: #{top_fixture_base_name}_tournament_team"
      w.puts "  top_team_score: #{tournament_match_up[3]}"
      w.puts "  bottom_tournament_team: #{bottom_fixture_base_name}_tournament_team"
      w.puts "  bottom_team_score: #{tournament_match_up[5]}"
    end
  end
else
  TournamentMatchUp.delete_all
  TournamentTeam.delete_all
  Team.delete_all
  #---------------Load Teams------------
  Team.import([:id, :name, :short_name, :city, :state], teams, validate: false)
  #---------------Load Teams------------

  #---------------Load TournamentTeams------------
  TournamentTeam.import([:id, :year, :team_id, :rank], tournament_teams, validate: false)
  #---------------Load TournamentTeams------------
  #---------------Load TournamentMatchUps------------
  TournamentMatchUp.import(
    [:id, :game, :top_tournament_team_id, :top_team_score, :bottom_tournament_team_id, :bottom_team_score],
    tournament_match_ups,
    validate: false
  )
  #---------------Load TournamentMatchUps------------
end
