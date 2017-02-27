//
//  WConstants.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 13/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

//API Endpoint and FTP credentials
var apiUrl: String = ""
var ftpName: String = ""
var ftpPass: String = ""
var apiPrefix = "/api/v1/"

//API Names
let kAPINameSignUp = "\(apiPrefix)Users/CreateNewUser"
let kAPINameGetCityState = "getCityState"
func kAPINameLogin(_ username:String,password:String) -> String {return "\(apiPrefix)Users/{\(username)}/Get/{\(password)}/Login"}

func kAPINameGenerateAccessCode(_ username:String) -> String {return "\(apiPrefix)Users/{\(username)}/GenerateResetCode"}
func kAPINameResetPassword(_ username:String,password:String,accessCode:String) -> String {return "\(apiPrefix)Users/{\(username)}/post/{\(password)}/reset/{\(accessCode)}/ChangePasswordWithCode"}
func kAPINameGetUser(_ id:String) -> String {return "\(apiPrefix)Users/{\(id)}/Get"}
func kAPINameUpdateUser()->String { return "\(apiPrefix)Users/Update" }
func kAPINameCreateLesson()->String { return "\(apiPrefix)Lessons/CreateNewLesson"}
func kAPINameGetVehicle(_ id:String) -> String {return "\(apiPrefix)Vehicles/{\(id)}/Get"}
func kAPINameGetDriverVehicles(_ id : String) -> String {return "\(apiPrefix)Vehicles/{\(id)}/GetDriverVehicles"}
func kAPINameGetAllCards(_ userId : String) -> String {return "\(apiPrefix)Users/{\(userId)}/GetCards"}
func kAPINameDeleteVehicle(_ id : String) -> String {return "\(apiPrefix)Vehicles/{\(id)}/Delete"}
func kAPINameAddCard(_ userId : String, token : String) -> String {return "\(apiPrefix)Users/{\(userId)}/Put/{\(token)}/AddCard"}
func kAPINameDeleteCard(_ userId : String, cardId : String) -> String {return "\(apiPrefix)Users/{\(userId)}/Delete/{\(cardId)}/DeleteCard"}
func kAPINameGetHistoryInfo(_ userId:String,driverId:String) -> String {return "\(apiPrefix)Lessons/{\(userId)}/Get/{\(driverId)}/History"}
func kAPINameGetAvailableStudentLessons(_ id:String,latitude:Double,longitude:Double) ->  String {return "\(apiPrefix)Lessons/{\(id)}/GetAvailableLessons/{\(latitude)}/At/{\(longitude)}/Location"}
func kAPINameGetAvailableDriverLessons(_ driverId:String,isInstructor:Bool,latitude:Double,longitude:Double) -> String {return "\(apiPrefix)Lessons/{\(driverId)}/Get/{\(isInstructor)}/AvailableLessons/{\(latitude)}/At/{\(longitude)}/Location"}

func kAPINameGetLesson(_ id:String)->String { return "\(apiPrefix)Lessons/{\(id)}/Get"}
func kAPINameCreateNewVehicle()->String { return "\(apiPrefix)Vehicles/CreateNewVehicle"}
func kAPINameUpdateVehicle()->String { return "\(apiPrefix)Vehicles/Update"}
func kAPINameGetRates()->String{ return "\(apiPrefix)Payments/GetRates"}

func kAPINameClaimLesson(_ lessonId:String,driverId:String)->String { return "\(apiPrefix)Lessons/{\(lessonId)}/Put/{\(driverId)}/ClaimLesson"}
func kAPINameUnclaimLesson(_ lessonId:String,driverId:String)->String { return "\(apiPrefix)Lessons/{\(lessonId)}/Put/{\(driverId)}/UnclaimLesson"}
func kAPINameDeleteLesson(_ lessonId:String)->String { return "\(apiPrefix)Lessons/{\(lessonId)}/Delete"}
func kAPINameUpdateLesson()->String { return "\(apiPrefix)Lessons/Update"}
func kAPINameSetupDriverPaymentsProfile() -> String { return "\(apiPrefix)Users/SetupDriverPaymentProfile"}
func kAPINameGetSetupDetails(_ userId : String) -> String { return "\(apiPrefix)Users/{\(userId)}/GetSetupDetails"}
func kAPINameStartLessonStudent(_ lessonId:String,studentId:String) -> String {return "\(apiPrefix)Lessons/{\(lessonId)}/Put/{\(studentId)}/StartLessonStudent"}
func kAPINameStartLessonDriver(_ lessonId:String,driverId:String) -> String {return "\(apiPrefix)Lessons/{\(lessonId)}/Put/{\(driverId)}/StartLessonDriver"}
func kAPINameFinishLesson(_ lessonId:String,userId:String) -> String {return "\(apiPrefix)Lessons/{\(lessonId)}/Put/{\(userId)}/FinishLesson"}
//func kAPINameRateLesson(_ userId:String,rating:String, lessonId:String) -> String {return "\(apiPrefix)Users/{\(userId)}/Put/{\(rating)}/ForLesson/{\(lessonId)}/RateUser"}
func kAPINameRateLesson() -> String {return "\(apiPrefix)Users/RateUser"}
func kAPINameSaveDeviceToken(_ userId: String, deviceToken: String) -> String {return "\(apiPrefix)Users/{\(userId)}/Post/{\(deviceToken)}/SaveToken"}
func kAPINameGetUserReviews(_ userId : String) -> String {return "\(apiPrefix)Users/{\(userId)}/GetUserReviews"}
func kAPINameConfirmRejectLesson(_ lessonId : String, isConfirmed: Bool) -> String {return "\(apiPrefix)Lessons/\(lessonId)/Put/\(isConfirmed)/ConfirmRejectLesson"}

//Parameters Names
let WUserID = "userId"
let WUserName = "username"
let WUserPassword = "password"
let WUserFName = "firstName"
let WUserLName = "lastName"
let WUserCity = "city"
let WUserCountry = "country"
let WUserPic = "pic"
let WUserDriver = "isDriver"
let WUserInstructor = "isInstructor"
let WUserLicenseLevel = "licenseLevel"
let WUserLicenseNumber = "licenseNumber"
let WUserPhoneNumber = "phoneNumber"
let WtempPassword = "tempPassword"
let WAccessCode = "code"
let WDateTime = "dateTime"
let WLatitude = "locLatitude"
let WLongitude = "locLongitude"
let WDuration = "duration"
let WStudentID = "studentId"
let WInstructorRequired = "instructorRequired"
let WUTCDateTime = "utcDateTime"
let WLessonID = "lessonId"
let WVehicleID = "vehicleId"
let WDriverID = "driverId"
let WMake = "make"
let WModel = "model"
let WYear = "year"
let WVin = "vin"
let WAvailableForTest = "availableForTest"
let WTransmissionType = "transmissionType"
let WIsMain = "isMain"
let WBase64Pic = "base64pic"
let WAmount = "amount"
let WStripeToken = "token"
let WCardId = "cardId"
var WZipCode = "zipCode"
var WState = "state"
var WAddressLine1 = "addressLine1"
var WBirthDay = "birthDay"
var WBirthMonth = "birthMonth"
var WBirthYear = "birthYear"
var WIp = "ip"
var WStatus = "status"
var WDetails = "details"
var WPersonalIdNumber = "personalIdNumber"
var WRating = "rating"
var WDeviceToken = "deviceToken"
var WText = "text"
var WType = "type"
var WConfirmed = "isConfirmed"

// Misc
let numbersCharSet = CharacterSet(charactersIn:"0123456789").inverted




