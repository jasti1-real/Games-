# Neon Football Arena — Android 3D prototype

**Built by Ivan Jokene**

This is the initial Godot 4 project for a FIFA-style camera football game intended for Android.

## Current prototype
- Procedurally generated 3D pitch and goal frames
- Follow camera above and behind the controlled player
- Keyboard controls for desktop testing
- Touchscreen direction, pass, and shoot buttons
- Ball physics and several simple AI teammates/opponents
- More detailed procedural placeholder footballers with heads, hair, eyes, arms, shorts, legs, and boots
- FIFA-style follow camera
- Basic score and match timer

## Important status
This is an early playable prototype, not a finished commercial football game. The current players are still procedural placeholders with simple facial details, not realistic scanned faces or licensed professional-player likenesses. Realistic player models, rigging, running/kicking animations, better AI, match rules, sound, menus, and performance testing are later development tasks. Use original or properly licensed player assets.

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
