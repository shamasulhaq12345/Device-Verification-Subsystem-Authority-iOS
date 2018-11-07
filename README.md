# DVS Authority Android App
##	System Requirements
###	Software Requirements
-	Xcode 9.4.1
-	Minimum iOS version 9.0
-	Mac OS 10.13.4

##	Keycloak Configuration
-	Login in IAM
-	Go to “Clients” section
-	Click on “DVS-app”  client
-	In settings tab write callback URL “com.qualcomm.auth.entity.dvs://oauth2Callback” in “Valid Redirect URL” field


##	App Configuration
-	To change any icon open Assets.xcaassets file in Xcode and select required icon
- Open info.plist file and add IAM URL in “IamUrl” field
-	Enter Realm name in “Realm” field
-	Enter Client ID in “ClientId” field
-	Enter URL of API Gateway in “ApiGatewayUrl” field
