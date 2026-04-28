# ExaVortex

ExaVortex is a facewashing of ExagonPlus Game for Windows and Android powered by **PLX Engine**

**PLX Engine** is now developing in parallel as an separate project folder package with the game requeriments

## Requirements

### **ExaVortex**: Game UI
* Title Screen
* Level Selector
### **ExaVortex**: Logic
* Gameplay (min. three levels)
    * Entities
        - Background (custom shape)
        - Center (custom shape)
        - Player
        - Walls
    * Components
        - Rotators
        - Chronometer
        - Entity generator for walls
    * Modules
        - Level Scripting (via Dart)
        - Scoreboards Backend (Supabase, may SQLite be necessary)

### **PLX**: Modules
#### **Core**
- Resources
- GameLoop (the Flutter widget is **PlxGame**)
- SceneManager
- Entity-Component System

#### **Collision System**
- Broad Phase
- Narrow Phase (SAT check)

#### **Custom-Made Graphic Engine** (using Flutter GPU + Impeller Render engine)
- Shader GLSL build assets
- Materials
- Support for custom buffers

#### **Audio Engine abstraction**
- Implementation on soLoud 
