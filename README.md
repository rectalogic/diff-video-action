# diff-video-action

A GitHub action that compares a set of videos to reference videos,
and generates audio/visual diff videos if any fail to compare visually/audibly identical.

Useful for regression testing video generation tools -
to detect changes in the output compared to a set of reference videos.

Assuming you have reference videos in `fixtures/*.mp4`,
then this will compare new videos in `output/` and upload
an artifact with the new videos and the visual diff.

```yaml
on: [push]

jobs:
  generate-videos:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ffmpeg
        run: sudo apt-get install ffmpeg
      - name: Encode new videos
        run: |
          mkdir output
          ffmpeg -f lavfi -i testsrc -t 2 -y output/test.mp4
      - name: Compare videos
        uses: rectalogic/diff-video-action@v1
        with:
          current-video-path: output
          reference-video-glob: fixtures/*.mp4
          diff-video-path: output/diff
      - name: Upload failed videos
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: diff-videos
          path: output
```
