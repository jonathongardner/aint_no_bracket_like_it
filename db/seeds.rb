unless Rails.env.test?
  TournamentMatchUp.delete_all
  TournamentTeam.delete_all
  Team.delete_all
  #---------------Load Teams------------
  teams = File.open(File.join(Rails.root, 'db', 'seeds', 'teams.csv')).map do |line|
     line.gsub!("\n", '').split(',')[0..3]
  end
  Team.import([:id, :name, :city, :state], teams, validate: false)
  #---------------Load Teams------------

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
