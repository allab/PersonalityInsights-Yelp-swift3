
# PersonalityInsights-Yelp-swift3
 Demo iOS app on integration of Personality Insights Bluemix Service Instance with Yelp API

## Setting up the services
To run an app, register the following API applications

* Facebook API. Register your app at https://developers.facebook.com/docs 
The source code is using Facebook API as a data source. Make sure you add the bundle identifier on the setup page.

* Yelp API. Register a new application at https://www.yelp.com/developers/documentation/v3 and update YelpAPIController file with new credentials. Authentication Type - OAuth 2.0

* Personality Insights Instance. Login to https://console.ng.bluemix.net and create Personality Insights Service Instance. Access usename/password info under Service Credentials tab. Authentication Type - Basic.

