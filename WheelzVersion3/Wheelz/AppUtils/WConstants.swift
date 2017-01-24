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

//API Names
let kAPINameSignUp = "/api/Users/CreateNewUser"
let kAPINameGetCityState = "getCityState"
func kAPINameLogin(_ username:String,password:String) -> String {return "/api/Users/{\(username)}/Get/{\(password)}/Login"}

func kAPINameGenerateAccessCode(_ username:String) -> String {return "/api/Users/{\(username)}/GenerateResetCode"}
func kAPINameResetPassword(_ username:String,password:String,accessCode:String) -> String {return "/api/Users/{\(username)}/post/{\(password)}/reset/{\(accessCode)}/ChangePasswordWithCode"}
func kAPINameGetUser(_ id:String) -> String {return "/api/Users/{\(id)}/Get"}
func kAPINameUpdateUser()->String { return "/api/Users/Update" }
func kAPINameCreateLesson()->String { return "/api/Lessons/CreateNewLesson"}
func kAPINameGetVehicle(_ id:String) -> String {return "/api/Vehicles/{\(id)}/Get"}
func kAPINameGetDriverVehicles(_ id : String) -> String {return "/api/Vehicles/{\(id)}/GetDriverVehicles"}
func kAPINameGetAllCards(_ userId : String) -> String {return "/api/Users/{\(userId)}/GetCards"}
func kAPINameDeleteVehicle(_ id : String) -> String {return "/api/Vehicles/{\(id)}/Delete"}
func kAPINameAddCard(_ userId : String, token : String) -> String {return "/api/Users/{\(userId)}/Put/{\(token)}/AddCard"}
func kAPINameDeleteCard(_ userId : String, cardId : String) -> String {return "/api/Users/{\(userId)}/Delete/{\(cardId)}/DeleteCard"}
func kAPINameGetHistoryInfo(_ userId:String,driverId:String) -> String {return "/api/Lessons/{\(userId)}/Get/{\(driverId)}/History"}
func kAPINameGetAvailableStudentLessons(_ id:String) ->  String {return "/api/Lessons/{\(id)}/GetAvailableLessons"}
func kAPINameGetAvailableDriverLessons(_ driverId:String,isInstructor:Bool,lattitude:Double,longitude:Double) -> String {return "/api/Lessons/{\(driverId)}/Get/{\(isInstructor)}/AvailableLessons/{\(lattitude)}/At/{\(longitude)}/Location"}

func kAPINameGetLesson(_ id:String)->String { return "/api/Lessons/{\(id)}/Get"}
func kAPINameCreateNewVehicle()->String { return "/api/Vehicles/CreateNewVehicle"}
func kAPINameUpdateVehicle()->String { return "/api/Vehicles/Update"}
func kAPINameGetRates()->String{ return "/api/Payments/GetRates"}

func kAPINameClaimLesson(_ lessonId:String,driverId:String)->String { return "/api/Lessons/{\(lessonId)}/Put/{\(driverId)}/ClaimLesson"}
func kAPINameUnclaimLesson(_ lessonId:String,driverId:String)->String { return "/api/Lessons/{\(lessonId)}/Put/{\(driverId)}/UnclaimLesson"}
func kAPINameDeleteLesson(_ lessonId:String)->String { return "/api/Lessons/{\(lessonId)}/Delete"}
func kAPINameUpdateLesson()->String { return "/api/Lessons/Update"}
func kAPINameSetupDriverPaymentsProfile() -> String { return "/api/Users/SetupDriverPaymentProfile"}
func kAPINameGetSetupDetails(_ userId : String) -> String { return "/api/Users/{\(userId)}/GetSetupDetails"}
func kAPINameStartLessonStudent(_ lessonId:String,studentId:String) -> String {return "/api/Lessons/{\(lessonId)}/Put/{\(studentId)}/StartLessonStudent"}
func kAPINameStartLessonDriver(_ lessonId:String,driverId:String) -> String {return "/api/Lessons/{\(lessonId)}/Put/{\(driverId)}/StartLessonDriver"}
func kAPINameFinishLesson(_ lessonId:String,userId:String) -> String {return "/api/Lessons/{\(lessonId)}/Put/{\(userId)}/FinishLesson"}
func kAPINameRateLesson(_ userId:String,rating:String, lessonId:String) -> String {return "/api/Users/{\(userId)}/Put/{\(rating)}/ForLesson/{\(lessonId)}/RateUser"}
func kAPINameSaveDeviceToken(_ userId: String, deviceToken: String) -> String {return "/api/Users/{\(userId)}/Post/{\(deviceToken)}/SaveToken"}

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

// Misc
let numbersCharSet = CharacterSet(charactersIn:"0123456789").inverted




