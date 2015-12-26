# ImageMagick snippets

## Slice Image into Tiles

Here's a one-liner to convert an image into a collection of tiles:

```
convert -crop 16x16@ file.png  tile_%d.png
```
