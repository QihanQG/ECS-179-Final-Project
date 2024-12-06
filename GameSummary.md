***Art styles:*** top-down view, and arctic theme. Single level and a single town. Enemies will spawn nearby to attack it. Blocky styles are similar to Roblox.

***Objective***: Survive a specific amount of stages, Protect the town, and prevent monsters from breaching the wall and killing the King Penguin. If the king penguin dies, the player will have no ability to deploy any more units or command anything else in the game. Each following stage will have more enemies.

***Unit/Weapons***: 

**Turrets**: Turrets can use different types of projectiles. Part exercise 3 and “split” project from ECS 179 GitHub system as reference.

* **Behavior**:  
  * Turret auto locks on and aims at the enemies closest to the wall by default, but the player can change its behavior with given options  
* **Placement:**  
  * Inside the tower  
  * Can be placed outside the tower  
  * Turrets can only fire *x* amount of shots per second. And cool down mechanics  
* The turret can have shields to protect against enemies, particularly from projectiles. The shield will use exercise 3 for reference  
* Turret  attributes can be upgraded in research buildings

***Enemies***:

* **Spawn**:   
  * Near the town.  
  * Enemies will continue to spawn?  
* **Pathfinding:**  
  * Predefined paths or follow a fixed path to reach the objective( destroy the wall)   
  * Once inside, they will attack the nearest buildings, turrets, or penguins.  
* **Types of enemies**:   
  * Enemies that use physical attack or fire projectiles  
* Can be knocked back or other behavior depending on the projectile types?

**The town:**

* The tower or town has a shield and wall protecting it.   
* Inside the town, It has 3 buildings:  
  * **The castle at the center**: Where king penguins(player) and other penguins reside.  
	* The castle produces x amount of penguins per given amount of time.  
	* Can assign these penguins to the research or factoring building or wall:
				  research building    -> increse resource cap
				  factory              -> build faster 
  * **The research building**:   
	* Can upgrade : 
				  weapon               -> higher base damage
  *               wall                 -> reduce incoming damage
	*               resources            -> gain more resources per time frame
  * **The factory**:   
	* Responsible for producing turrets and items. 

**Resource systems:**

* Passive overtime  
* After completing each wave  
* Bonus for good performance( the town takes less damage)  
* Managed by a single mining/production building?  
  * 

**King Penguin:** 

* If it dies, the player can’t use any command or deploy any more turrets  
* Controllable by the player?  
* Can you run away from the enemies?

**Effects:**

* Shield has similar effects to exercise 3, including when being hit by projectiles  
* Wall effects when being destroyed( yes or no)?  
  *   
* Projectile effects:  
  * Bullet:   
  * Cannon:  
  * Other:   
* Buildings destruction:  
  *   
* Enemies attacks:  
  * 

**GameLoop:**

* The game is over when 80%  of the town is destroyed  
* After each stage ends, you are given x amount of time until the next stage starts.  
* You win the game when the town survives all the stages
