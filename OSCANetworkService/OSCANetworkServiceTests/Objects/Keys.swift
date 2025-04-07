//
//  Keys.swift
//  OSCANetworkServiceTests
//
//  Created by Stephan Breidenbach on 07.07.22.
//

import Foundation
/// coding keys for `Info.plist`
public enum Keys {
  public enum Plist {
    public static let defaultGeoPointLatitude  = "DEFAULT_GEO_POINT_LATITUDE"  //
    public static let defaultGeoPointLongitude = "DEFAULT_GEO_POINT_LONGITUDE" //
    public static let parseAPIRootURL          = "PARSE_API_ROOT_URL"          //
    public static let parseAPIKey              = "PARSE_API_KEY"               //
    public static let parseRESTAPIKey          = "PARSE_REST_API_KEY"          //
    public static let parseMasterAPIKey        = "PARSE_MASTER_API_KEY"        //
    public static let parseAPIApplicationID    = "PARSE_API_APPLICATION_ID"    //
    public static let devParseAPIRootURL       = "PARSE_API_ROOT_URL_DEV"      //
    public static let devParseRESTAPIKey       = "PARSE_REST_API_KEY_DEV"      //
    public static let devParseMasterAPIKey     = "PARSE_MASTER_API_KEY_DEV"    //
    public static let devParseAPIApplicationID = "PARSE_API_APPLICATION_ID_DEV"//
    public static let devParseAPIKey           = "PARSE_API_KEY_DEV"           //
    public static let imageAPIRootURL          = "ImageBaseURL"                //
    public static let launchScreenTitle        = "LaunchScreenImageName"       //
    public static let splashAnimationName      = "SplashAnimationName"         //
    public static let launchScreenImageName    = "LaunchScreenImageName"       //
    public static let homeTabItems             = "homeTabItems"                //
    public static let deeplinkScheme           = "DEEPLINK_SCHEME"             //
    public static let environment              = "ENVIRONMENT"                 //
  }// end enum Plist
}// end enum Keys
