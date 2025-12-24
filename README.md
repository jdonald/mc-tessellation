# mc-tessellation

A custom shader to be used with Minecraft Java Edition via OptiFine or Sodium+Iris

## Behavior

A custom shader that makes most visible voxel-style surfaces tessellated into triangles. Cubes and rectangles will thus look rounder, but keep the LOD low enough such that generated triangles remain identifiable as triangles, so the result looks more like a mid-way tech demo of DirectX tessellation, but not to the extreme of tessellating so small that the surfaces look fully round.
