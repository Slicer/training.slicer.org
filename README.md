# training.slicer.org

The `training.slicer-org` branch of this repository stores the files deployed at https://training.slicer.org.

The site is implemented using [jekyll static site generator](https://jekyllrb.com/) and uses the [Bulma clean theme](https://github.com/chrisrhymes/bulma-clean-theme).
It is generated leveraging the static site implemented in https://github.com/Slicer/slicer.org.

## Production

The branch [training-slicer-org][branch-training-slicer-org]  is automatically updated using the GitHub Action workflow
described in [.github/workflows/build-website.yml](.github/workflows/build-website.yml) when any of the following are updated:
* [training.markdown][file-training-markdown]
* [_data/tutorial.yml][file-tutorial-yml]
* SHA of the version of [Slicer/slicer.org][github-slicer-org] hard-coded in [build.sh][file-build-sh]

[branch-training-slicer-org]: https://github.com/Slicer/slicer.org/tree/training-slicer-org
[file-build-sh]: https://github.com/Slicer/training.slicer.org/blob/main/build.sh
[file-training-markdown]: https://github.com/Slicer/training.slicer.org/blob/main/training.markdown
[file-tutorial-yml]: https://github.com/Slicer/training.slicer.org/blob/main/_data/tutorial.yml
[github-slicer-org]: https://github.com/Slicer/slicer.org

## License

It is covered by the MIT License:

https://github.com/Slicer/training.slicer.org/blob/main/LICENSE.md
