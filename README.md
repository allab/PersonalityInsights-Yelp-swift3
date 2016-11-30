
# PersonalityInsights-Yelp-swift3
 Demo iOS app on integration of Personality Insights Bluemix Service Instance with Yelp API. App is integrated with Facebook iOS SDK and is using user's posts as a data source for personality insights service. Application suggests places nearby based on user consumption preferences and a search term provided.


## Setting up the services
To run an app, register the following API applications

* Facebook API. Register your app at https://developers.facebook.com/docs 
The source code is using Facebook API as a data source. Make sure you add the bundle identifier on the setup page.

* Yelp API. Register a new application at https://www.yelp.com/developers/documentation/v3 and update YelpAPIController file with new credentials. Authentication Type - OAuth 2.0

A valid category search field list: https://www.yelp.ca/developers/documentation/v2/category_list

* Personality Insights Instance. Login to https://console.ng.bluemix.net and create Personality Insights Service Instance. Access usename/password info under Service Credentials tab. Authentication Type - Basic.


## Facebook SDK and SwiftKeychainWrapper via cocoapods

Add a pod file to your project https://cocoapods.org and add the following dependencies 
- pod 'FacebookCore'
-	pod 'FacebookLogin'
- pod 'FacebookShare'
-	pod 'SwiftKeychainWrapper'


## Screens

<img src="/screens/PreferencesVC.png?raw=true" height="350" alt="Preferences View Controller Screen">    <img src="/screens/ResultsTableVC.png?raw=true" height="350" alt="Results Table View Controller Screen">    <img src="/screens/BusinessDetailsVC.png?raw=true" height="350" alt="Business Details View Controller Screen">
