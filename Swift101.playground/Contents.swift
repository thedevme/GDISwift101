//: Playground - noun: a place where people can play

import UIKit

let numValue = 32
let numFloat = 23.1
let isVisible = false
let isFound = false

let numVersion:Float = 1.1
let lessPrecisePI = Float("3.14")
let morePrecisePI = Double("3.141526536")

if isVisible {
    print("i am visible")
} else {
    print("i am not visible")
}

// Here is a comment 
/* 
 asdfasdf
 sdfasdf
 sadfasdf
 */
 
if numValue < 30 {
    print("yes ")
}
else {
    print("greater than 30")
}

var strNotAnOptional = "not optional"
var strOptional:String?
strOptional = "this is an optional"


if let str = strOptional {
    print(str)
}

func greet(with name:String, last:String) {
    print("hello \(name) \(last)")
}

greet(with: "craig", last: "clayton")



let isPictureVisible = true

if isPictureVisible {
    print("Picture is visible")
}

let isRestaurantFound = false

if isRestaurantFound == false {
    print("Restaurant was not found")
}

let numDrinkingAgeLimit = 19

if numDrinkingAgeLimit < 21 {
    print("Since we cannot offer you an adult beverage - would you like a water or soda to drink?")
}

if numDrinkingAgeLimit < 21 {
    print("Since we cannot offer you an adult beverage - would you like a water or soda to drink?")
}
else {
    print("What type of beverage would you like?  We have adult beverages along with water or soda to drink.")
}

let strRestaurantName = "La Bamba"

if strRestaurantName == "La Bamba" {
    print("I've only been to La Bamba II!")
}
else {
    print("Oh! I've never heard of that restaurant")
}

if strRestaurantName == "La Bamba" {
    print("I've only been to La Bamba II!")
}
else if strRestaurantName == "La Bamba II" {
    print("This restaurant is excellent!")
}
else {
    print("Oh! I've never heard of that restaurant")
}


let range = 10...20
let halfClosedRange = 10..<20

for value in range  {
    print("closed range - \(value)")
}

for index in halfClosedRange  {
    print("half closed range - \(index)")
}

for index in 0...3  {
    print("range inside - \(index)")
}

for index in (10...20).reversed()  {
    print("reversed range - \(index)")
}

var y = 0

while y < 50 {
    y += 5
    print("y:\(y)")
}

var x = 0

repeat {
    x += 5
    print("x:\(x)")
} while x < 100

print("repeat completed x: \(x)")

repeat {
    x += 5
    print("x:\(x)")
} while x < 100

print("repeat completed again x: \(x)")


// ARRAYS

// Create
let arrOfInts:[Int] = []
let arrStrings = [String]()

// Create initial values
let arrOfMoreInts = [54, 29]

// Mutable
var arrStates:[String] = []

// arrStates.append(23) // You will get an error if you uncomment
arrStates.append("Florida")
arrStates.insert("Ohio", at: 1)
arrStates.insert(contentsOf: ["North Carolina", "South Carolina", "Nevada"], at: 2)
arrStates += ["Texas", "Colorado"]
print(arrStates.count)


if arrStates.isEmpty {
    print("There are no items in the array")
}
else {
    print("There are currently (arrStates.count) total items in our array")
}

let strState = arrStates[2]
print(strState)
let strState2 = arrStates[1]
print(strState2)

if let index = arrStates.index(of:"South Carolina") {
    print("Current index position is \(index)")
}

if let index = arrStates.index(of:"South Carolina") {
    arrStates[index] = "Arizona"
}

// add loop first
arrStates.removeFirst()

for state in arrStates {
    print(state)
}


arrStates.remove(at:2)
arrStates.remove(at:4)
arrStates.removeAll()
