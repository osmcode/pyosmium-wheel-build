**Retirement warning: these scripts have now been archived. Wheel building
can be found in the Github action scripts of the original pyosmium repo.**

Build wheel distribution for pyosmium.

build.sh script is usefull for testing and generates locally wheels in dist directory.

.travis.yml script builds wheels and uploads them into the release. You need to configure
`GITHUB_API_KEY` in travis settings for this repository and this API keys needs `public_repo` permission
