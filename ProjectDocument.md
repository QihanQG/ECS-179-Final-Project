# Game Basic Information #

## Summary ##

The penguins are in trouble! Mischievous seals and bears are invading their icy home, trying to steal their fish reserves. As the leader of the penguin patrol, it’s up to you to build snow forts, fire snowball cannons, and unlock special abilities to protect the colony. But watch out! The seals and bears won’t give up easily! Get ready for a frosty adventure and defend the Arctic!

## Gameplay Explanation ##

The players can move around the map using `WSDA` keys and `all mouse click` buttons. To start the game player can either choose new game to enter. Once entered, the player will set up tower defenses and click the "Ready" button on the screen when they want the round to begin.

Movement: Move by using the keys `WSDA`. Press `W` to go forward; `S` to move backwards; `D` to go right; `A` to go left: `scroll-wheel up` to zoom in; `scrool-wheel down ` to zoom out.

Turret placement: `mouse left-click` to select anything on the UI including turret options.

Cancel: `mouse right-click` to cancel

Pause: `ESC` to pause or quit the game entirely.

# Main Roles #

## Producer

**Describe the steps you took in your role as producer. Typical items include group scheduling mechanisms, links to meeting notes, descriptions of team logistics problems with their resolution, project organization tools (e.g., timelines, dependency/task tracking, Gantt charts, etc.), and repository management methodology.**

*Name: Cheng-yuan Liu*   
*Email: cgyliu@ucdavis.edu*   
*Github: *ccc2d8850

## User Interface and Input

*Name: Brian Nguyen*   
*Email: btinguyen@ucdavis.edu*   
*Github: briantinnguyen*

### User Interface

My primary task in the development of our tower defense game focused on the user interface and input, ensuring that the game was intuitive, responsive, and enjoyable for players. One of my first responsibilities was designing a wireframe for the layout, which served as a blueprint for the game's user interface. I started by mapping out the key elements the players would need to interact with during gameplay. The layout included elements like the enemy's spawn point, the road, the end road, the overall design for the enemy path and the town. I was resposible for creating the path.

<img src="imgs/Layout.jpg" alt="" width="800" height="475">

Main Menu: The main menu serves as the player's entry point to the game. It provides options such as starting a new game, loading a saved game, and exiting the game entirely. The main menu was made by duplicating the main world node, which allowed it to be implemented with a clean, intuitive user interface. In addition to the main menu, I added a 360-camera rotation around the map so that users can experience the game environment dynamically.

Pause Menu: The pause menu is implemented to provide players with essential controls during the gameplay. It is an important feature that enhances user interaction by offering options to resume or quit the game. The pause menu was built within the main node while the main menu was built my duplicating the entire environment and switching scenes once a load or new game has been selected.  

<img src="imgs/Main.png" alt="" width="400" height="200"> <img src="imgs/Pause.png" alt="" width="400" height="200">

Ready: The ready function is implemented within the UI to enhance players' experience and strategy. This function activates when the player clicks on the "Ready" button on the map, triggering the start of the game and spawning the monster. This is designed to give players a fair chance to prepare their defenses before each wave. This ensures that players can come up with a strategy before each round.

<img src="imgs/ready2.png" alt="" width="400" height="200"> <img src="imgs/ready.png" alt="" width="400" height="200">

Tower Weapon HUD: The tower weapon head consists of draggable buttons on the main camera screen, allowing players to choose and place turrets during the game. This feature is meant to enhance the gameplay by allowing the players to choose and place turrets before and during the waves. The turret buttons are placed on the top right screen to ensure players' visibility. The draggable functionality makes it easier for players to position their turret exactly where they want.

<img src="imgs/hud.png" alt="" width="400" height="200">

### Input

In addition to the UI responsibilities, I also implemented the game's top-down view and input controls. The top-down view is crucial for giving players a clear perspective of the tower defense and, fundamentally, the players use the top-down view angle. I positioned the camera so that it also ensures that it captures the entire play of the area while maintaining the game's arctic theme. For the input controls, the focus was to create a smooth and intuitive experience for navigating the map. WSDA keys were the main controls for camera movement. The mouse scroll wheel is for zooming in and out. The camera boundaries were also set up to ensure that players do not leave the designated game environment.

<img src="imgs/controls.png" alt="" width="400" height="200">

## Movement/Physics

**Describe the basics of movement and physics in your game. Is it the standard physics model? What did you change or modify? Did you make your movement scripts that do not use the physics system?**

*Name: Penelope Phan*   
*Email: peaphan@ucdavis.edu*   
*Github: *

## Animation and Visuals

*Name: Maxim Saschin*   
*Email: mnsaschin@ucdavis.edu*   
*Github: MaximSaschin*

### 3D Models and Assets
The objective for our 3D game was to create a visually cohesive experience where the characters, assets, and objects complemented each other seamlessly. As a team, we decided on an arctic-themed tower defense game in which penguins defend their precious supply of fish against waves of enemies, including seals and polar bears. From the outset, we envisioned a cartoonish, Roblox-inspired aesthetic—partially blocky, colorful, and intentionally unrealistic—to give the game an engaging arcade feel.

To bring this vision to life, I began searching for free-to-use assets online. During this process, I discovered [poly.pizza](https://poly.pizza/), a great resource offering thousands of free, high-quality poly 3D models. This platform became my go-to in sourcing most of the asset models for our game, from characters to environmental elements. By leveraging these assets, we were able to achieve a consistent and playful visual style that aligned with our creative direction and gameplay mechanics.

**List your assets, including their sources and licenses.**
With poly.pizza I was able to find many of the character models that we used for our game inluding:

* Penguin - https://poly.pizza/m/2GSHsxaDIo
* Turret - https://poly.pizza/m/ekTQhbJId7 
* Castle - https://poly.pizza/m/opTOmcN3o9 
* Igloo - https://poly.pizza/m/4CNw6ZPb4x3
* Tree - https://poly.pizza/m/3pWKPFASEn-

<img src="scripts/pengiuncharacter.jpg" alt="pengiuncharacter" width="225" height="200"><img src="scripts/turret.jpg" alt="turret" width="200" height="200"><img src="scripts/castle.jpg" alt="castle" width="250" height="200">
<img src="scripts/igloo.jpg" alt="igloo" width="200" height="200"><img src="scripts/tree.jpg" alt="tree" width="150" height="200">

I downloaded these assets from poly.pizza as .glb files and imported them directly into our project under assets -> models. Here, other members of the group could use the assets for their portions of the game development. 

### Animation
I have limited experience animating 2D sprites and no prior experience animating 3D models or assets. However, I used a program called [Maximo](https://www.mixamo.com/), which simplifies the 3D animation process significantly. I started by importing a character asset from poly.pizza and positioned joints at key areas such as the knees, wrists, chin, and groin of the 3D model. Mixamo then automatically generated a skeleton with weights (rigs) and applied animations to the model.

<img src="scripts/maximo_work.jpg" alt="maximo_work" width="550" height="350"><img src="scripts/maximo.jpg" alt="maximo" width="800" height="400"><img src="scripts/penguinrun-ezgif.com-video-to-gif-converter.gif" alt="penguinrun" width="300" height="400">

Since Mixamo is designed for human-like characters, the animations are tailored to mimic human movements rather than animals. To work around this limitation, I selected a humanoid penguin character from poly.pizza to ensure the animations functioned correctly. Given the tight time constraints, this approach was the most efficient solution for animating the character.

If I had more time, I would have explored creating custom rigs and animations in Blender. This would have allowed me to animate non-humanoid characters, such as four-legged animals, expanding the possibilities for the game.

### Map/World-Building
**Describe how your work intersects with game feel, graphic design, and world-building. Include your visual style guide if one exists.**

When designing the map for our game, we decided to create a single, well-crafted map, as it aligned well with the mechanics and objectives of our tower defense gameplay. In most tower defense games, the map remains constant while the variables—such as the number of enemies, their difficulty, or their spawn frequency—change over time. Additionally, the map serves as a "sandbox" for players, providing a space where they can strategically place turrets and defenses to combat waves of enemies. Switching between maps as the game progresses would have disrupted this core gameplay loop and diminished the strategic depth we wanted to offer.

As I helped with the world-building, I was responsible for crafting the icy terrain and adding environmental details to bring our arctic theme to life. I used a Godot plugin called [Heightmap Terrain](https://godotengine.org/asset-library/asset/231) to sculpt the landscape, creating mountain ridges and hill-like terrain to serve as natural borders for the map. Beyond shaping the terrain, I positioned several 3D models, such as an igloo where the enemies spawn, a castle that the enemies are trying to attack, and other structures, to define the map's visual identity and strategic points. To enhance the game's overall feel, I incorporated smaller details like scattered trees, ice walls, and other environmental elements, creating a visually engaging and immersive arctic battlefield. These touches not only improved the map's aesthetic but also contributed to the game's atmosphere, making it more enjoyable and memorable for players.

<img src="scripts/mapoverview.jpg" alt="mapoverview" width="800" height="500">

## Game Logic

**Document the game states and game data you managed and the design patterns you used to complete your task.**

*Name: Qihan Guan*   
*Email: qgguan@ucdavis.edu*   
*Github: *

My role initially included handling the enemy and unit(turret) behaviors, but it became a broader role in the overall Game logic. I first implemented yaw rotation (horizontal) using basic vector math, using dot product to find the angle between the turret's forward vector and target vector, cross product's Y component, and using the sign to determine rotation direction (clockwise/counterclockwise). The next challenge was adding pitch rotation (vertical) and handling both axes concurrently and seamlessly with respect to the turret design. Which required me to change my initial approach from a simple vector-math based to a more complex approach that could handle both rotational axes simultaneously. Eventually, I learned that I could put separate pivot points on the turret model to handle the yaw rotations and pitch rotations separately. And use arctangent calculations for pitch angles. And implemented angle constraints for the turret's movements to remain realistic and within its design limitations.

After this, I spent time refining the turret movements, implementing more features/modes,  adding more debugging features, and making it more modular for other members to approach and modify. Then finally implementing it on the turret models provided by Maxim, it was a bit challenging as the model meshes only have two parts, the base and top. But I was able to make it work with some tricks.

<img src="imgs/turret_prototype.png" alt="seal" width="400" height="200"><img src="imgs/turret_1.png" alt="igloo" width="400" height="200">

<img src="imgs/turret_2.png" alt="seal" width="400" height="200">

Next, I implemented the durative movement commands for the enemies, initially, this was Penelope Phan's role but we decided to switch and she provided me with the initial template/implementation. But we didn't have our enemy model yet, So I found a Lego model to use as zombies and used Adobe Mixamo to do the auto-rigging. Getting this set up in Godot was trickier than I expected, I hadn't done much with animations/designs before, so I spent quite a bit of time figuring out how to properly structure the scene and model to work with the animations. The biggest headache was fixing issues where the meshes and skeleton transforms didn't line up correctly, especially during animations. Once I got past those hurdles I was able to use my experience from exercise 1 to implement the durative cmds scripts for the zombie movement. The main challenge was handling transitions during animation replays, especially for the walk animation. The starting position didn’t match the ending position, which caused a noticeable reset when the animation looped. After some time I  discovered I could disable translation to keep the character in place while playing the animation

![](https://github.com/QihanQG/ECS-179-Final-Project/blob/main/imgs/zombie_walk_reset.gif)

disabling the transformation.

![](https://github.com/QihanQG/ECS-179-Final-Project/blob/main/imgs/zombie_walk_.gif)

Then I work with Cheng Yuan to implement the building/town scripts. Given the time constraint, we decided to keep it simple. The research building passively upgrades turret attributes as long as its health remains above 20%. But only newly spawned turrets inherit these upgrades. The production building spawns turrets at predefined fortress points, tracking availability and only spawning at unoccupied locations.

*Name: Cheng-yuan Liu*   
*Email: cgyliu@ucdavis.edu*   
*Github: *ccc2d8850

#### assets:
Lego" (https://skfb.ly/MEGs) by Jody_Hong 
(http://creativecommons.org/licenses/by/4.0/). Rigging and animations by Adobe mixamo

# Sub-Roles

## Weapons System/ Debugging

*Name: Qihan Guan*   
*Email: qgguan@ucdavis.edu*   
*Github: *

My sub role is practically the same as my main, the general game logic and mechanics. This involves debugging scripts or fixing scenes.

## Audio

**List your assets, including their sources and licenses.**

**Describe the implementation of your audio system.**

**Document the sound style.** 

*Name: Penelope Phan*   
*Email: peaphan@ucdavis.edu*   
*Github: *

## Gameplay Testing

*Name: Maxim Saschin*   
*Email: mnsaschin@ucdavis.edu*   
*Github: MaximSaschin*

**link to the full results of my gameplay tests:**

[Observations and Playtester Comments](imgs/Observations_and_Playtester_Comments.pdf)

### Playtesting Feedback Summary

During playtesting sessions, two players provided feedback on various aspects of the game. While they appreciated the foundational concept and visual elements, several areas for improvement were identified.

Key Observations:
Game Concept & Visuals:
Players liked the arctic theme, 3D visuals, and tower-defense style, which were described as engaging. However, both agreed that the gameplay felt basic and lacked depth.

Clarity & Objectives:

The objective of defending the castle from zombies was generally understood, but players noted a lack of clear instructions or a tutorial, causing initial confusion.
One player wasn’t sure how to place turrets, while another didn’t immediately understand the game’s goal.
Gameplay Mechanics:

Players found the mechanics intuitive but limited, with repetitive gameplay and a lack of variety in turrets, enemies, and abilities.
Suggestions included adding more rounds, diverse mechanics, and narrative elements similar to games like Plants vs. Zombies.
Bugs & Errors:

Zombies occasionally walked off the map or didn’t damage the castle, breaking immersion.
The animations for zombies changing direction felt clunky.
User Interface & Controls:

Theming of buttons didn’t fully match the game’s aesthetic.
A tutorial screen with controls and game rules was requested for better onboarding.
The high camera angle made gameplay difficult to follow.

Suggested Improvements:
* Gameplay Enhancements: Add more turrets, enemy types, abilities, and longer rounds to increase complexity and engagement. Incorporate a story or narrative for a more cohesive experience.
* Bug Fixes: Ensure zombies behave as intended and can damage the castle. Address animation clunkiness.
* Onboarding: Create a tutorial or onboarding screen to explain controls, rules, and objectives clearly.
* Polish: Refine user interface elements to match the game’s theme, and adjust the camera for better visibility.
* Replayability: Introduce new mechanics to prevent repetitiveness and enhance long-term player interest.
* Target Audience: The game is aimed at fans of tower defense games, especially kids and teenagers, due to its simplicity.

With these improvements, playtesters agreed the game has strong potential to deliver a more enjoyable and polished experience.

## Narrative Design

**Document how the narrative is present in the game via assets, gameplay systems, and gameplay.** 
 
*Name: Cheng-yuan Liu*   
*Email: cgyliu@ucdavis.edu*   
*Github: *ccc2d8850

## Game Feel and Polish

*Name: Brian Nguyen*   
*Email: btinguyen@ucdavis.edu*   
*Github: briantinnguyen*

For game feel, one of the key improvements I made was addressing the brightness issue in the game. Initially, the game environment was too dark, which made it difficult for players to see the map and its contents. To fix this issue, I added a sun scene to enhance the lighting giving the game a more aesthetically pleasing environment. 

Additionally, I worked on positioning key structures like igloos, and our defense tower ensuring they all fit into their correct positions. I was responsible for creating the path and made improvements by cleaning up the terrain's blockage. The terrain was improved by smoothing out the surfaced, layering, and removing.

<img src="imgs/dark.png" alt="" width="400" height="150"> <img src="imgs/bright.png" alt="" width="400" height="150"> <img src="imgs/cleanup.png" alt="" width="400" height="150">

## Press Kit and Trailer

*Name: Brian Nguyen*   
*Email: btinguyen@ucdavis.edu*   
*Github: briantinnguyen*

**Include links to your presskit materials and trailer.**

When making the trailer for Pengine Patrol: Arctic Defense, I wanted to show off the main parts of the game in a fun and simple way. The trailer starts with a quick look at the icy Arctic and the penguin colony, then jumps into gameplay. You see snowball cannons firing, penguins building forts, and seals trying to steal fish. I made sure to include special moves, like icy blasts, to show how exciting the game gets. The trailer ends with a big call to action: "Protect the Arctic!"

I picked music that felt exciting and fun, adding sound effects like snowballs hitting seals to bring it to life. For the screenshots, I chose scenes that show the coolest parts of the game—penguins fighting back, seals charging in, and the icy Arctic world. I kept it simple, making sure everything looks fun and clear for anyone who sees it.

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)  
