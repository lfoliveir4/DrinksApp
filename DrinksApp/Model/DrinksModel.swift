import Foundation

struct DrinksResponse: Codable {
    let drinks: [Drink]
}

struct Drink: Codable {
    let strDrink: String
    let strDrinkThumb: String
    let idDrink: String
}
