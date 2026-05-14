import Foundation

final class LocalStorageService {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        do {
            let data = try encoder.encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Save error (\(key)): \(error)")
        }
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("Load error (\(key)): \(error)")
            return nil
        }
    }
}
