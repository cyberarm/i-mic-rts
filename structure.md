# I-MIC RTS - Structure
* Dependancy Trees
  * Entity
  * Director
  * Player
* Networking

## Dependancy Trees
### Entity
An entity requires access to Director

### Director
The Director requires access to most everything as its purpose is to: sync commands to and from other players (local and remote), to execute said commands on the correct tick, and to be the primary for entities to gain access to required features and functions outside of the Director.
