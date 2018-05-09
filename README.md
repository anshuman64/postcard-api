# insiya-api

## Setup
1. Open .bash_profile (create the file if it does not exist).
````
open ~/.bash_profile
````
Add the following lines:
````
export ONE_SIGNAL_APP_ID="Ask Anshuman for the key"
export ONE_SIGNAL_AUTH_KEY="Ask Anshuman for the key"
export PUSHER_KEY="Ask Anshuman for the key"
export PUSHER_SECRET="Ask Anshuman for the key"
export TWILIO_ACCOUNT_SID="Ask Anshuman for the key"
export TWILIO_AUTH_TOKEN="Ask Anshuman for the key"
````

## Release
### Quick Release
0. Uncomment all "Debug Test" code (Twilio SMS and OneSignal push notifications)!
1. Make sure all code is COMMITTED to current branch
1. Run command:
````
eb deploy insiya-production-server-1
````

### Full Release
0. Uncomment all "Debug Test" code (Twilio SMS and OneSignal push notifications)!
1. Log into AWS Console: https://console.aws.amazon.com/
2. Click "Services" > "Compute" > "Elastic Beanstalk"
3. Click "insiya-production-server-1" or "insiya-production-server-2"
4. Click "Actions" > "Clone Environment"
5. Change "Environment name" to the opposite of the existing environment (1 vs. 2) and click "Clone"
6. Wait for environment to build...
7. Make sure all code is COMMITTED to current branch (or else it gives a warning)
8. Run command:
````
eb deploy insiya-production-server-1
````
9. Wait for environment to update in AWS Console...
10. On Elastic Beanstalk application page, click "Actions" > "Swap Environment URLs"
11. Click "Okay"
12. Done! Production API calls will now be routed to the new, updated environment
