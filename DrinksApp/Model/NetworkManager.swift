import Foundation

enum ResponseDrinksError: Error {
    case badURL, noData, invalidJson
}

public final class NetworkManager {
    public static let shared = NetworkManager()

    struct Constants {
        public static let api = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Shake")
    }

    private init() {}

    func getDrinks(completion: @escaping (Result<[Drink], ResponseDrinksError>) -> Void) {
        guard let url = Constants.api else {
            completion(.failure(.badURL))
            return
        }

        let configuration = URLSessionConfiguration.default

        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completion(.failure(.invalidJson))
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(DrinksResponse.self, from: data)
                completion(.success(result.drinks))
            } catch {
                print("Error info: \(error.localizedDescription)")
                completion(.failure(.noData))
            }
        }

        task.resume()
    }
}
