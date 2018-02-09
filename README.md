# insiya-api

## Setup - General
1. Open .bash_profile (create the file if it does not exist).
````
open ~/.bash_profile
````
Add the following lines:
````
export ONE_SIGNAL_APP_ID='Ask Anshuman for the key'
export ONE_SIGNAL_AUTH_KEY='Ask Anshuman for the key'
export PUSHER_KEY='Ask Anshuman for the key'
export PUSHER_SECRET='Ask Anshuman for the key'
````

## Release - General
1. Log into AWS Console: https://console.aws.amazon.com/
2. Click 'Services' > 'Compute' > 'Elastic Beanstalk'
3. Click 'insiya-production-server-1' or 'insiya-production-server-2'
4. Click 'Actions' > 'Clone Environment'
5. Change 'Environment name' to the opposite of the existing environment (1 vs. 2) and click 'Clone'
6. Wait for environment to build...
7. In terminal, make sure latest code is committed to master branch in git
8. In terminal, type:
````
eb deploy insiya-production-1
````
9. Wait for environment to update in AWS Console...
10. On Elastic Beanstalk application page, click 'Actions' > 'Swap Environment URLs'
11. Click 'Okay'
12. Done! Production API calls will now be routed to the new, updated environment


