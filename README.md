### docker-artifactory-pro
Use this repo's Docker Compose files to start the version of Artifactory OSS or Pro to develop applications or processes that need a private artifact repository. For example, if you're developing Chef cookbooks that need packages that are not available on the Internet, or are cut off from you by a proxy, you can fire up Artifactory in Docker and get to downloading, yumming, apt-getting, or whatever you need to do.

#### OSS
`docker-compose -f docker-compose-arty-oss.yml up` to start the open source version of Artifactory

#### Pro
`docker-compose -f docker-compose-arty-pro.yml up` to start the open source version of Artifactory.  Notables:
* you'll have to have license keys to use Pro, either input into the Artifactory web console after you start, or set as environment variables before you compose up.
* you can run Artifactory Pro in HA mode if you have two license keys and set the right environment variables.
* you can run Artifactory Pro in an external database, again with the right environment variables (mariadb is used the Docker compose file for Artifactory pro).

####Environment Variables
For now, see [arty_env.sh](https://github.com/flacito/docker-artifactory-pro/blob/master/arty_env.sh) on setting up your environment before compose up. More details coming to the readme soon.
