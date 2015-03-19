# travis_versioning

This is the versioning scheme we use with Travis CI. After a build, Travis uploads a deb to S3, and another system downloads it, signs the package, and then adds it to our apt repo (also hosted on S3).

This file gets downloaded by Travis and `cat`ed together with some project specific info to construct a full asset file.
