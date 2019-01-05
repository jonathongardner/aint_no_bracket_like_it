require 'json'
schools = {}
File.open('schools.csv').each do |line|
  school = line.gsub!("\n", '').split(',')
  raise 'Same name schools! Oh no!' if schools.key?(school[1])
  # name => id
  schools[school[1]] = school[0]
end
game_number_mapping = {
  1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9,
  10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 32,
  18 => 31, 19 => 30, 20 => 29, 21 => 28, 22 => 27, 23 => 26, 24 => 25, 25 => 24,
  26 => 23, 27 => 22, 28 => 21, 29 => 20, 30 => 19, 31 => 18, 32 => 17, 33 => 33,
  34 => 34, 35 => 35, 36 => 36, 37 => 37, 38 => 38, 39 => 39, 40 => 40, 41 => 48,
  42 => 47, 43 => 46, 44 => 45, 45 => 44, 46 => 43, 47 => 42, 48 => 41, 49 => 49,
  50 => 50, 51 => 51, 52 => 52, 53 => 56, 54 => 55, 55 => 54, 56 => 53, 57 => 57,
  58 => 58, 59 => 60, 60 => 59, 61 => 61, 62 => 62, 63 => 63
}

@name_mappings = {
  "SMU" => "Southern Methodist Mustangs",
  "Loyola–Chicago" => "Loyola (IL) Ramblers",
  "Georgia" => "Georgia Bulldogs",
  "Illinois" => "Illinois Fighting Illini",
  "St John's" => "St. John's (NY) Red Storm",
  "Southern" => "Southern Jaguars",
  "Iowa" => "Iowa Hawkeyes",
  "Arkansas" => "Arkansas Razorbacks",
  "Washington" => "Washington Huskies",
  "Kentucky" => "Kentucky Wildcats",
  "UNLV" => "Nevada-Las Vegas Rebels",
  "UTEP" => "Texas-El Paso Miners",
  "NC State" => "North Carolina State Wolfpack",
  "Nevada" => "Nevada Wolf Pack",
  "Alabama" => "Alabama Crimson Tide",
  "Arizona" => "Arizona Wildcats",
  "VCU" => "Virginia Commonwealth Rams",
  "Michigan" => "Michigan Wolverines",
  "Michigan*" => "Michigan Wolverines",
  "Maryland" => "Maryland Terrapins",
  "LSU" => "Louisiana State Fighting Tigers",
  "Kansas" => "Kansas Jayhawks",
  "Ohio" => "Ohio Bobcats",
  "North Carolina" => "North Carolina Tar Heels",
  "Middle Tennessee State" => "Middle Tennessee Blue Raiders",
  "Oklahoma" => "Oklahoma Sooners",
  "Duke" => "Duke Blue Devils",
  "UAB" => "Alabama-Birmingham Blazers",
  "Memphis State" => "Memphis Tigers",
  "Penn" => "Pennsylvania Quakers",
  "Virginia" => "Virginia Cavaliers",
  "Indiana" => "Indiana Hoosiers",
  "Jacksonville" => "Jacksonville Dolphins",
  "Arkansas–Little Rock" => "Little Rock Trojans",
  "Northeast Louisiana" => "Louisiana-Monroe Warhawks",
  "Missouri" => "Missouri Tigers",
  "Utah" => "Utah Utes",
  "TCU" => "Texas Christian Horned Frogs",
  "Florida" => "Florida Gators",
  "Houston" => "Houston Cougars",
  "Southwest Missouri State" => "Missouri State Bears",
  "BYU" => "Brigham Young Cougars",
  "San Diego" => "San Diego Toreros",
  "Texas A&M" => "Texas A&M Aggies",
  "UTSA" => "Texas-San Antonio Roadrunners",
  "UC Santa Barbara" => "UC-Santa Barbara Gauchos",
  "Kentucky#" => "Kentucky Wildcats",
  "North Texas State" => "North Texas Mean Green",
  "South Carolina" => "South Carolina Gamecocks",
  "Tennessee" => "Tennessee Volunteers",
  "Idaho" => "Idaho Vandals",
  "Texas" => "Texas Longhorns",
  "Connecticut" => "Connecticut Huskies",
  "California" => "University of California Golden Bears",
  "Towson State" => "Towson Tigers",
  "SW Missouri State" => "Missouri State Bears",
  "New Mexico" => "New Mexico Lobos",
  "Saint Peters" => "Saint Peter's Peacocks",
  "Montana" => "Montana Grizzlies",
  "Wisconsin–Green Bay" => "Green Bay Phoenix",
  "Massachusetts" => "Massachusetts Minutemen",
  "Southwest Louisiana" => "Louisiana Ragin' Cajuns",
  "Ohio St " => "Ohio State Buckeyes",
  "Delaware" => "Delaware Fightin' Blue Hens",
  "USC" => "Southern California Trojans",
  "Southern Illinois" => "Southern Illinois Salukis",
  "Tennessee State" => "Tennessee State Tigers",
  "UCF" => "Central Florida Knights",
  "Southwest Texas State" => "Texas State Bobcats",
  "UW–Green Bay" => "Green Bay Phoenix",
  "UNC Charlotte" => "Charlotte 49ers",
  "FIU" => "Florida International Panthers",
  "Oregon" => "Oregon Ducks",
  "Monmouth" => "Monmouth Hawks",
  "Portland" => "Portland Pilots",
  "UNC Greensboro" => "North Carolina-Greensboro Spartans",
  "UNC-Greensboro" => "North Carolina-Greensboro Spartans",
  "UNC Asheville" => "North Carolina-Asheville Bulldogs",
  "UNC-Asheville" => "North Carolina-Asheville Bulldogs",
  "UNC Wilmington" => "North Carolina-Wilmington Seahawks",
  "UNC-Wilmington" => "North Carolina-Wilmington Seahawks",
  "Colorado" => "Colorado Buffaloes",
  "Ole Miss" => "Mississippi Rebels",
  "UIC" => "llinois-Chicago Flames",
  "Prairie View A&M" => "Prairie View Panthers",
  "Valparaíso" => "Valparaiso Crusaders",
  "SW Missouri St." => "Missouri State Bears",
  "Kent St." => "Kent State Golden Flashes",
  "Miami-FL" => "Miami (FL) Hurricanes",
  "Miami-OH" => "Miami (OH) RedHawks",
  "Miami (Ohio)" => "Miami (OH) RedHawks",
  "Louisiana-Lafayette" => "Louisiana Ragin' Cajuns",
  "Louisiana–Lafayette" => "Louisiana Ragin' Cajuns",
  "St. Louis" => "Saint Louis Billikens",
  "Jackson St." => "Jackson State Tigers",
  "Fresno St." => "Fresno State Bulldogs",
  "Indiana St." => "ndiana State Sycamores",
  "Southeast Missouri St." => "Southeast Missouri State Redhawks",
  "Troy St" => "Troy Trojans",
  "UW–Milwaukee" => "Milwaukee Panthers",
  "UT-Chattanooga" => "Chattanooga Mocs",
  "Texas A&M-CC" => "Texas A&M-Corpus Christi Islanders",
  "Washington St." => "Washington State Cougars",
  "St. Joseph's" => "Saint Joseph's Hawks",
  "Boise St." => "Boise State Broncos",
  "Portland St." => "Portland State Vikings",
  "Kansas St." => "Kansas State Wildcats",
  "UMBC" => "Maryland-Baltimore County Retrievers",
  "Texas–Arlington" => "Texas-Arlington Mavericks",
  "Miss Valley St." => "Mississippi Valley State Delta Devils",
  "WKU" => "Western Kentucky Hilltoppers",
  "East Tennessee St." => "East Tennessee State Buccaneers",
  "Mississippi" => "Mississippi Rebels",
  "NC Central" => "North Carolina Central Eagles",
  "Buffalo" => "Buffalo Bulls",
  "UC Irvine" => "UC-Irvine Anteaters",
  "Northwestern" => "Northwestern Wildcats",
  "North Dakota" => "North Dakota Fighting Hawks",
  "UC Davis" => "UC-Davis Aggies"
}
def fix_name(t)
  @name_mappings[t['team']] || t['team']
end

File.open(File.join('games.csv'), 'w') do |file|
  (1985..2018).to_a.each do |year|
    games_in_tournament = JSON.parse(File.read(File.join('json', "#{year}.json")))
    games_in_tournament.each_with_index do |g, index|
      our_team_names0 = schools.keys.select { |s| s.include?(fix_name(g[0])) }
      our_team_names1 = schools.keys.select { |s| s.include?(fix_name(g[1])) }

      raise "School no found #{g[0]} #{year} : #{our_team_names0} : 0-#{index}" unless our_team_names0.count == 1
      raise "School no found #{g[1]} #{year} : #{our_team_names1} : 1-#{index}" unless our_team_names1.count == 1

      region = nil
      case g[0]['round_of']
      when 64 # 32 games
        region = (index / 8).floor
      when 32 # 16 games
        region = ((index - 32) / 4).floor
      when 16 # 8 games
        region = ((index - 48) / 2).floor
      else
        # only do 56 because 4 and 5 should be region champs vs and 60 -56
        # only do 56 because 6 should be champs vs and 62 - 56
        region = (index - 56)
      end
      # game#, year, region, top_team_id, top_team_seed, top_team_points, bottom_team_id, bottom_team_seed, bottom_team_points, round_of
      to_write = [
        game_number_mapping[index + 1], year, region, schools[our_team_names0[0]], g[0]['seed'], g[0]['score'], schools[our_team_names1[0]], g[1]['seed'], g[1]['score'], g[0]['round_of']
      ]
      file.puts(to_write.join(','))
    end
  end
end
