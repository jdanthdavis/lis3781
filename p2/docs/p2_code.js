//1. Display all documents in collection
db.restaurants.find();

//2. Display the number of documents in collection
db.restaurants.find().count();

//3. Retrieve 1st 5 documents
db.restaurants.find().limit(5)

//4. Retrieve restaurants in the Brooklyn borough
db.restaurants.find( { "borough":"Brooklyn" } )

//5. Retrieve restaurants whose cuisine is American
db.restaurants.find( {cuisine": "American " } )

//6. Retrieve restaurants whose borough is Manhattan and cuisine is hamburgers
db.restaurants.find( { "borough": "Manhattan", "cuisine": "Hamburgers" } )

//7. Display the number of restaurants whose borough is Manhattan and cuisine is hamburgers
db.restaurants.find( { "borough": "Manhattan", "cuisine": "Hamburgers" } ).count()

//8. Query zipcode field in embedded address document
    // retrieve restaurants in the 10075 zip code area.
db.restaurants.find( {" address.zipcode: "10075" }, { "_id" : 0, "address.zipcode" : 1 } )

//9. Retrieve restaurants whose cuisine is chicken and zip code is 10024
db.restaurants.find( { "cuisine": "Chicken", "address.zipcode": "10024" } )

//10. Rertrieve restaurants who cuisine is chicken or whose zip code is 10024
db.restaurants.find( { $or: [ { "cusisine": "Chicken" }, { "address.zipcode": "10024" } ] } )

//11. Retrieve restaurants whose borough is Queens, cuisine is Jewish/kosher, sort by descending order of zipcode
db.restaurants.find( { "borough": "Queens", "cuisine": "Jewish/Kosher" } ).sort({"address.zipcode": -1})

//12. Retrieve restaurants with a grade A
db.restaurants.find( { "grades.grade": "A" } )

//13. Retrieve restaurants with a grade A, displaying only collection id, restaurant name, and grade
db.restaurants.find( { "grades.grade": "A" }, { "name": 1, "grades.grade: 1" } )
db.restaurants.find( { "grades.grade": "A" }, { "name": 1, "grades.grade: 1" } ).count()

//14. Retrieve restaurants with a grade A, displaying only restaurant name, and grade (no collection id)
db.restaurants.find( { "grades.grade": "A" }, {"name": 1, "grades.grade": 1, _id: 0 } )
db.restaurants.find( { "grades.grade": "A" }, {"name": 1, "grades.grade": 1, _id: 0 } ).count()

//15. Retrieve restaurants with a grade A, sort by cuisine ascending, and zip code descending
db.restaurants.find( { "grades.grade": "A" } ).sort({"cuisine": 1, "address.zipcode": -1 } )

//16. Retrieve restaurants with a score higher than 80
db.restaurants.find( { "grades.score": { $gt: 80 }} )

//17. Insert a record with the folllowing data
db.restaurants.find().limit(1).pretty()

db.restaurants.insert(
    {
        "address" : {
            "street" : "7th Avenue",
            "zipcode" : "10024",
            "building" : "1000",
            "coord" : [ -58.9557413, 31.7720266 ],
        },
        "borough" : "Brooklyn",
        "cuisine" : "BBQ",
        "grades" : [
            {
                "date" : ISODate("2015-11-05T00:00:00Z"),
                "grade" : "C",
                "score" : 15
            }
        ],
        "name" : "Big Tex",
        "restaurant_id" : "61704627"
    }
)

db.restaurant_id.find().sort({_id:-1}).limit(1).pretty();

//18. Change the first White Castle restaurant document's suisine to "Steak and Sea Food", and upddate the lastModified field with the current date
db.restaurant_id.find( { "name" : "White Castle" } )

db.restaurant.update(
    { "_id" : ObjectId("5e9a487816f10d0e10d5fcb1") },
    {
        $set: { "cuisine" : "Steak and Sea Food" }, $currentDate: { "lastModified":true }
    }
)

//19. Delete all White Castle restaurants (Remove All Documents that Match a Condition)
db.restaurant.find( { "name" : "White Castle" }, { "name": 1, "cuisine": 1, _id: 0}).count()

db.restaurant.remove( { "name": "White Castle" } )

db.restaurant.find( { "name" : "White Castle" }, { "name" : 1, "cuisine" : 1, _id:0}).count()

db.restaurant.remove( { } )
db.restaurant.count()

db.restaurant.remove( { "_id" : ObjectId("5981d6277c7e084888c84c3e") } )

db.restaurant.remove( { "name" : "White Castle" }, true )

db.mycollection.drop()