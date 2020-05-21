fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios archive
```
fastlane ios archive
```
Archive framework
### ios bump_version
```
fastlane ios bump_version
```
Bump new version
### ios deploy
```
fastlane ios deploy
```
Deploy
### ios release
```
fastlane ios release
```

### ios lint
```
fastlane ios lint
```
Linting source code
### ios bootstrap
```
fastlane ios bootstrap
```
Bootstrap carthage
### ios update
```
fastlane ios update
```
Update dependencies
### ios test
```
fastlane ios test
```
Run unit testing
### ios clean
```
fastlane ios clean
```
Clean project

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
