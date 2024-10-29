# frozen_string_literal: true

require 'bcrypt'

questions = [
  { statement: 'You come across a hive of bees', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find an abandoned campfire', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find a shallow stream', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find a stream', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You come across an unknown plant', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find a group of mushrooms', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You encounter a thunderstorm', typeCard: 'Hard', leftclicks: 0, rightclicks: 0 },
  { statement: 'You meet a group of survivors', typeCard: 'Hard', leftclicks: 0, rightclicks: 0 },
  { statement: 'You meet a wounded wolf', typeCard: 'Hard', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find an abandoned backpack', typeCard: 'Easy', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find a dark cave', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find a fruit tree', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'It\'s getting a little cold', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You come across a stream with small fish swimming near the shore', typeCard: 'Medium', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You find a colony of insects under a rotten log', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You discover a bird\'s nest with several eggs inside', typeCard: 'Medium', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You find a puddle with stagnant water and some mosquito larvae', typeCard: 'Medium', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You find several worms after a rain', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You come across a small river crab in a stream', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You see a non-venomous snake near your shelter', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find a group of snails in a damp area', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You see a frog near a pond', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You come across a bush with unknown berries', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You need to build a fire for warmth and cooking.', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find a water source that looks clean.', typeCard: 'Easy', leftclicks: 0, rightclicks: 0 },
  { statement: 'You encounter a snow-covered area and need to make a fire base.', typeCard: 'Hard', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You are in a frigid area with only snow and ice around you.', typeCard: 'Medium', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You are stranded at sea with no fresh water.', typeCard: 'Hard', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find yourself on a deserted beach with no obvious fresh water source.', typeCard: 'Medium',
    leftclicks: 0, rightclicks: 0 },
  { statement: 'You are in a desert with extremely limited water sources.', typeCard: 'Hard', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You are in a jungle with various plants and trees around.', typeCard: 'Easy', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You find an ideal spot for a shelter', typeCard: 'Easy', leftclicks: 0, rightclicks: 0 },
  { statement: 'You need to quickly build a shelter to protect yourself from the cold', typeCard: 'Medium',
    leftclicks: 0, rightclicks: 0 },
  { statement: 'Your shelter has collapsed during a storm', typeCard: 'Hard', leftclicks: 0, rightclicks: 0 },
  { statement: 'You find yourself in a desert with limited water supply.', typeCard: 'Hard', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You discover an open wound on your leg.', typeCard: 'Hard', leftclicks: 0, rightclicks: 0 },
  { statement: 'You are feeling extremely tired after a long hike.', typeCard: 'Medium', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You come across a stream of water.', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You have a splitting headache and feel dizzy.', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 },
  { statement: 'You notice your urine is very dark and you feel weak.', typeCard: 'Hard', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You have an insect bite that is swelling.', typeCard: 'Easy', leftclicks: 0, rightclicks: 0 },
  { statement: 'You are in a cold environment without proper clothing.', typeCard: 'Hard', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'You see some berries that you are unsure are edible.', typeCard: 'Medium', leftclicks: 0,
    rightclicks: 0 },
  { statement: 'Your feet are developing blisters.', typeCard: 'Medium', leftclicks: 0, rightclicks: 0 }
]


questions.each do |t|
  Question.create(t)
end

options = [
  { question_id: 1, description: 'Try to steal some honey', effects: [-1, 1, 0, 0] },
  { question_id: 1, description: 'Leave the hive alone', effects: [0, -1, 0, 0] },
  { question_id: 2, description: 'Rekindle the campfire to keep warm', effects: [0, -1, -1, 3] },
  { question_id: 2, description: 'Ignore the campfire and move on', effects: [0, 0, 0, -1] },
  { question_id: 3, description: 'Go looking for fish', effects: [-1, 2, 0, -1] },
  { question_id: 3, description: 'Avoid it', effects: [0, -1, -1, 0] },
  { question_id: 4, description: 'Drink water from the stream', effects: [1, 1, 0, 0] },
  { question_id: 4, description: 'Distrust water and look for another source', effects: [0, 0, -1, 0] },
  { question_id: 5, description: 'Test the plant', effects: [-3, 0, 0, 0] },
  { question_id: 5, description: 'Ignore the plant', effects: [0, 0, 0, 0] },
  { question_id: 6, description: 'Collect and eat mushrooms', effects: [-2, 1, 0, 0] },
  { question_id: 6, description: 'Be wary of mushrooms and move on', effects: [0, -1, 0, 0] },
  { question_id: 7, description: 'Take shelter under a tree', effects: [-3, 0, 2, -3] },
  { question_id: 7, description: 'Find a safer refuge', effects: [0, 0, 3, -3] },
  { question_id: 8, description: 'Try to negotiate with them', effects: [-3, -2, -1, 0] },
  { question_id: 8, description: 'Avoid conflict and escape', effects: [0, 0, 0, -1] },
  { question_id: 9, description: 'Run', effects: [0, -1, -1, 1] },
  { question_id: 9, description: 'hunt the wolf', effects: [-3, 3, -2, -1] },
  { question_id: 10, description: 'Check backpack for supplies', effects: [0, 2, 3, 1] },
  { question_id: 10, description: 'Leave the backpack in its place', effects: [0, 0, 0, 0] },
  { question_id: 11, description: 'Explore the cave in search of shelter', effects: [1, 0, 0, -2] },
  { question_id: 11, description: 'Avoid the cave and continue traveling', effects: [0, -1, -1, 0] },
  { question_id: 12, description: 'Collect and eat the fruit', effects: [0, 2, 1, 0] },
  { question_id: 12, description: 'Distrust the fruit and move on', effects: [0, -1, -1, -1] },
  { question_id: 13, description: 'Create a campfire on the trail', effects: [0, -1, 0, 3] },
  { question_id: 13, description: 'Keep looking for shelter', effects: [0, -1, -1, -2] },
  { question_id: 14, description: 'Catch some fish and cook them', effects: [1, 2, 0, 0] },
  { question_id: 14, description: 'Drink directly from the stream without treating the water', effects: [-2, 0, 1, 0] },
  { question_id: 15, description: 'Collect and eat the insects after cooking them', effects: [0, 2, 0, 0] },
  { question_id: 15, description: 'Ignore the insects because they seem unpleasant', effects: [0, 0, 0, 0] },
  { question_id: 16, description: 'Take all the eggs and cook them', effects: [-1, 3, 0, 0] },
  { question_id: 16, description: 'Take only some eggs, leaving the rest for later', effects: [0, 2, 0, 0] },
  { question_id: 17, description: 'Drink the water without treating it because you are very thirsty',
    effects: [-3, 0, 2, 0] },
  { question_id: 17, description: 'Look for another cleaner water source', effects: [0, 0, 0, 0] },
  { question_id: 18, description: 'Eat the worms raw', effects: [-1, 2, 0, 0] },
  { question_id: 18, description: 'Purge the worms in clean water before eating them', effects: [0, 2, 0, 0] },
  { question_id: 19, description: 'Cook and eat the crab', effects: [0, 2, 0, 0] },
  { question_id: 19, description: 'Leave the crab and keep looking for food', effects: [0, 0, 0, 0] },
  { question_id: 20, description: 'Catch and cook the snake to eat it', effects: [1, 3, 0, 0] },
  { question_id: 20, description: 'Leave the snake alone and keep looking for food', effects: [0, 0, 0, 0] },
  { question_id: 21, description: 'Cook and eat the snails', effects: [0, 2, 0, 0] },
  { question_id: 21, description: 'Don\'t eat the snails because you are unsure if they are safe',
    effects: [0, 0, 0, 0] },
  { question_id: 22, description: 'Catch and cook the frog', effects: [0, 2, 0, 0] },
  { question_id: 22, description: 'Don\'t touch the frog because you don\'t know if it\'s poisonous',
    effects: [0, 0, 0, 0] },
  { question_id: 23, description: 'Eat the berries without knowing if they are safe', effects: [-3, 1, 0, 0] },
  { question_id: 23, description: 'Don\'t eat the berries and keep looking for known food', effects: [0, 0, 0, 0] },
  { question_id: 24, description: 'Use the tepee method to build a fire.', effects: [0, 1, 0, 1] },
  { question_id: 24, description: 'Use the lean-to method to build a fire.', effects: [0, 0, 0, 1] },
  { question_id: 25, description: 'Boil the water before drinking.', effects: [1, 0, 2, 0] },
  { question_id: 25, description: 'Drink the water as it is.', effects: [-2, 0, 2, 0] },
  { question_id: 26, description: 'Make a fire base using green logs.', effects: [0, 0, 0, 2] },
  { question_id: 26, description: 'Attempt to build a fire without a base.', effects: [0, 0, 0, -1] },
  { question_id: 27, description: 'Eat the snow or ice directly.', effects: [-2, 1, 0, -1] },
  { question_id: 27, description: 'Melt and purify the snow or ice before drinking.', effects: [1, -1, 2, 0] },
  { question_id: 28, description: 'Drink seawater directly.', effects: [-3, -2, -1, 0] },
  { question_id: 28, description: 'Use a desalinator to purify the seawater.', effects: [2, -2, 2, 0] },
  { question_id: 29, description: 'Dig a hole deep enough to allow water to seep in and boil it.',
    effects: [2, -1, 1, 0] },
  { question_id: 29, description: 'Look for green vegetation and dig behind the first group of sand dunes.',
    effects: [1, -1, 2, 0] },
  { question_id: 30, description: 'Search for cacti and cut off the top to extract water.', effects: [1, -2, 1, 0] },
  { question_id: 30, description: 'Follow animal trails to potential water sources.', effects: [1, -1, 1, 0] },
  { question_id: 31, description: 'Cut down a banana or plantain tree and scoop out water from the stump.',
    effects: [2, -1, 2, 0] },
  { question_id: 31, description: 'Use a bamboo stalk to collect water overnight.', effects: [2, -1, 2, 0] },
  { question_id: 32, description: 'Build a shelter using branches and leaves', effects: [0, -1, 0, 1] },
  { question_id: 32, description: 'Use a nearby natural cave', effects: [0, 0, 0, 2] },
  { question_id: 33, description: 'Make a shelter with a poncho', effects: [-1, 0, 0, 2] },
  { question_id: 33, description: 'Find a rock to shield yourself from the wind', effects: [0, 0, 0, 1] },
  { question_id: 34, description: 'Rebuild the shelter in the rain', effects: [-2, 0, 0, 0] },
  { question_id: 34, description: 'Find another area to make a new shelter', effects: [-1, 0, 0, 1] },
  { question_id: 35, description: 'Ration your remaining water strictly.', effects: [-1, 0, -1, 0] },
  { question_id: 35, description: 'Drink all the water you have to stay hydrated.', effects: [0, 0, 3, 0] },
  { question_id: 36, description: 'Clean the wound with available water and cover it.', effects: [2, 0, -1, 0] },
  { question_id: 36, description: 'Ignore the wound and keep moving.', effects: [-3, 0, 0, 0] },
  { question_id: 37, description: 'Take a rest under a shade.', effects: [1, 0, 0, -1] },
  { question_id: 37, description: 'Push through and keep hiking.', effects: [-2, 0, 0, 1] },
  { question_id: 38, description: 'Filter and drink the stream water.', effects: [1, 0, 2, 0] },
  { question_id: 38, description: 'Avoid drinking unknown water.', effects: [0, 0, -1, 0] },
  { question_id: 39, description: 'Rest and drink some water.', effects: [1, 0, 1, 0] },
  { question_id: 39, description: 'Ignore it and continue moving.', effects: [-2, 0, 0, 0] },
  { question_id: 40, description: 'Drink water immediately and rest.', effects: [2, 0, 1, 0] },
  { question_id: 40, description: 'Keep working without drinking water.', effects: [-2, 0, -2, 0] },
  { question_id: 41, description: 'Treat the bite with an anti-itch cream.', effects: [1, 0, 0, 0] },
  { question_id: 41, description: 'Leave the bite untreated.', effects: [-1, 0, 0, 0] },
  { question_id: 42, description: 'Build a fire to keep warm.', effects: [0, 0, 0, 2] },
  { question_id: 42, description: 'Move around to generate body heat.', effects: [-1, 0, -1, 1] },
  { question_id: 43, description: 'Eat the berries.', effects: [-2, 2, 0, 0] },
  { question_id: 43, description: 'Avoid eating the berries.', effects: [0, -1, 0, 0] },
  { question_id: 44, description: 'Rest and treat the blisters.', effects: [1, 0, 0, 0] },
  { question_id: 44, description: 'Ignore the blisters and keep walking.', effects: [-2, 0, 0, 0] }
]

options.each do |u|
  Option.create(u)
end

skills = [
  { name: 'fire',
    description: 'It is essential for survival in the wild. Provides heat to keep warm, helps cook food,
                  purify water and scare away dangerous animals. Additionally,
                  fire can be a source of light and morale in emergency situations.',
    dificulty: 'Easy' },
  { name: 'water',
    description: 'It is essential for life and survival. Without water,
                  the human body cannot function properly. In survival situations,
                  it is crucial to find sources of clean water or learn how to purify water to make it safe to drink.',
    dificulty: 'Medium' },
  { name: 'food',
    description: 'Provides the energy needed to stay active and healthy.
                  In survival situations, it is important to know how to identify and gather edible wild foods,
                  as well as hunting and fishing techniques. It is also helpful to carry emergency food with you,
                  such as energy bars or dehydrated foods.',
    dificulty: 'Medium' },
  { name: 'shelter',
    description: 'Protects from extreme weather and provides a safe place to rest.
                  In survival situations, shelter can be as simple as a makeshift shelter made of branches and leaves,
                  or as complex as a sturdy tent.',
    dificulty: 'Medium' },
  { name: 'medicine',
    description: 'In survival settings, medical care may be limited or nonexistent.
                  Therefore, it is important to have basic first aid knowledge and carry basic medical supplies,
                  such as bandages, disinfectants, and pain medications.',
    dificulty: 'Hard' }
]

skills.each do |t|
  Skill.create(t)
end

guides = [
  { title: 'fire', rute_content: '/assets/contets/guideFire', skill_id: 1 },
  { title: 'water', rute_content: '/assets/contets/guideWater', skill_id: 2 },
  { title: 'food', rute_content: '/assets/contets/guideFood', skill_id: 3 },
  { title: 'shelter', rute_content: '/assets/contets/guideShelter', skill_id: 4 },
  { title: 'medicine', rute_content: '/assets/contets/guideMedicine', skill_id: 5 }
]

guides.each do |u|
  Guide.create(u)
end

bars = [
  { name_bar: 'temperature', value: 10 },
  { name_bar: 'water', value: 10 },
  { name_bar: 'hunger', value: 10 },
  { name_bar: 'health', value: 10 }
]

bars.each do |u|
  Bar.create(u)
end

user = { username: 'ADMIN', nickname: 'ADMIN', password: BCrypt::Password.create('ADMIN'), coins: 999, admin: 1 }
User.create(user)
