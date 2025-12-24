# mc-tessellation

A custom shader pack for Minecraft Java Edition that adds tessellation effects to give blocks a distinctive geometric appearance.

## Overview

This shader pack makes Minecraft's voxel-style surfaces tessellated into visible triangles. Cubes and rectangles will look rounder and more geometric, creating a unique "tech demo" aesthetic reminiscent of DirectX tessellation demonstrations from the early 2010s.

## Behavior

The shader subdivides each triangle of Minecraft's block geometry into smaller triangles, then slightly displaces the new vertices to create a rounded, faceted appearance. The tessellation level is kept intentionally low so that individual triangles remain clearly visible - this gives blocks a distinctive geometric look rather than appearing fully smooth.

**Key features:**
- Configurable tessellation level (1-4 subdivisions)
- Adjustable surface smoothness
- Level-of-detail (LOD) system to avoid tessellating small/distant triangles
- Optimized performance with geometry shaders
- Terrain gets full tessellation, other objects get lighter treatment
- Entities (mobs) remain mostly untessellated for recognizability

## Installation

### Requirements
- Minecraft Java Edition (1.16 or higher recommended)
- **Either:**
  - **OptiFine** (HD U G8 or higher), OR
  - **Sodium + Iris Shaders** (recommended for better performance)

### Installation Steps

1. **Install shader loader:**
   - **For OptiFine:** Download from [OptiFine.net](https://optifine.net/) and install
   - **For Iris:** Download from [IrisShaders.net](https://irisshaders.net/) and install both Iris and Sodium

2. **Download this shader pack:**
   - Clone this repository or download as ZIP
   - The shader pack is in the `shaders/` folder

3. **Install the shader pack:**
   - Locate your Minecraft folder:
     - Windows: `%appdata%\.minecraft`
     - macOS: `~/Library/Application Support/minecraft`
     - Linux: `~/.minecraft`
   - Navigate to the `shaderpacks` folder (create if it doesn't exist)
   - Copy the entire `mc-tessellation` folder into `shaderpacks`

4. **Enable the shader:**
   - Launch Minecraft
   - Go to Options → Video Settings → Shaders
   - Select "mc-tessellation" from the list
   - Click "Done"

## Configuration

Access shader settings through:
- **OptiFine:** Options → Video Settings → Shaders → Shader Options
- **Iris:** Options → Video Settings → Shader Packs → (select shader) → Settings

### Settings

**Tessellation Level** (1-4, default: 2)
- **1 (Low):** Minimal subdivision - largest visible triangles, best performance
- **2 (Medium):** Balanced tessellation - recommended "tech demo" look
- **3 (High):** More subdivisions - smaller triangles, smoother curves
- **4 (Very High):** Maximum subdivisions - high GPU load

**Tessellation Smoothness** (0.0-1.0, default: 0.5)
- **0.0 (Flat):** No vertex displacement - blocks stay blocky
- **0.5 (Medium):** Moderate rounding - balanced geometric look
- **1.0 (Very Smooth):** Maximum displacement - very rounded appearance

## Technical Details

This shader pack uses GLSL 1.50 geometry shaders to achieve tessellation-like effects:

1. **Vertex Shader** prepares vertex data and normals
2. **Geometry Shader** subdivides triangles recursively and displaces vertices
3. **Fragment Shader** applies lighting and textures to the tessellated geometry

The tessellation algorithm:
- Subdivides each triangle into 4 smaller triangles (recursive)
- Displaces midpoint vertices along interpolated normals
- Applies LOD to skip tessellation for small/distant triangles
- Uses different tessellation levels for terrain vs. other geometry

**Performance notes:**
- Geometry shaders have some overhead; expect 10-30% FPS reduction
- Performance impact scales with tessellation level
- LOD system helps maintain FPS at distance
- Iris/Sodium typically performs better than OptiFine

## Compatibility

- ✅ Works with Minecraft 1.16+
- ✅ Compatible with OptiFine
- ✅ Compatible with Iris Shaders
- ⚠️ May conflict with other shader packs (use only one at a time)
- ⚠️ Performance varies by GPU; dedicated GPU recommended

## Known Limitations

- Entities (mobs, players) use minimal tessellation to avoid distortion
- Transparent surfaces may show artifacts with high tessellation
- Some texture mapping may appear slightly stretched on curved surfaces
- Not compatible with Minecraft's native rendering (requires OptiFine/Iris)

## Troubleshooting

**Shader won't load:**
- Ensure you have OptiFine or Iris installed correctly
- Check Minecraft version compatibility
- Verify the shader pack is in the correct folder

**Low FPS:**
- Reduce Tessellation Level to 1 or 2
- Lower Tessellation Smoothness
- Check GPU drivers are up to date

**Blocks look wrong:**
- Reset shader settings to default
- Ensure no other shader packs are active

## License

This project is licensed under the MIT License - see the LICENSE file for details.
