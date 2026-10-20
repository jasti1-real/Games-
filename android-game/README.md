# Neon Football Arena — Android 3D prototype

**Built by Ivan Jokene**

This is the initial Godot 4 project for a FIFA-style camera football game intended for Android.

## Current prototype
- Procedurally generated 3D pitch and goal frames
- Follow camera above and behind the controlled player
- Keyboard controls for desktop testing
- Touchscreen direction, pass, and shoot buttons
- Ball physics and several simple AI teammates/opponents
- More detailed procedural placeholder footballers with heads, hair, eyes, nose, ears, arms, shorts, legs, and boots
- Procedural arm and leg swing animations tied to player movement
- FIFA-style follow camera
- Basic score and match timer

## Important status
This is an early playable prototype, not a finished commercial football game. The current players are still procedural placeholders with simple facial details, not realistic scanned faces or licensed professional-player likenesses. Realistic player models and professional-grade rigging are still missing. The current procedural arm/leg swing is a simple prototype animation, not motion-captured football animation. Better AI, match rules, sound, menus, and performance testing remain development tasks. Use original or properly licensed player assets.

## Open in Godot
1. Install Godot 4.x on a computer.
2. Import this folder (android-game/project.godot).
3. Run Main.tscn.
4. Test keyboard controls: WASD/arrows to move, Space to pass, Enter to shoot.
5. Configure Android export templates and an Android SDK/JDK before exporting an APK.

## Android export
Godot's Android export templates and Android build toolchain must be installed on the build computer. This repository currently contains source project files, not a ready-to-install APK.

## Roadmap
1. Verify the 3D prototype runs in Godot 4 and fix any engine-version issues.
2. Add proper player rigs, original or licensed realistic character assets, and animations.
3. Improve ball possession, passing, shooting, tackling, goalkeeper behavior, and match flow.
4. Optimize touch controls and rendering for Android devices.
5. Export and test a signed APK on a real phone.

## World Stars roster plan
The planned World Stars XI includes Lionel Messi, Cristiano Ronaldo, Kylian Mbappe, Erling Haaland, Mohamed Salah, Vinicius Junior, Jude Bellingham, Kevin De Bruyne, Luka Modric, Sadio Mane, Son Heung-min, and Neymar Jr. The roster data is in `data/world_stars.json`.

**Licensing note:** These names are a planning roster only. The repository does not yet contain authentic face scans, official kits, club badges, or licensed likeness assets. Appropriate permissions are needed for commercial distribution of recognizable player likenesses. Until then, use original generic models and placeholder team branding.
