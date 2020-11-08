import ArgumentParser

struct MyTools: ParsableCommand {

    static let configuration =
        CommandConfiguration(
        abstract: "This is my tool",
        subcommands: [Random.self,
                      Pick.self,])

}

enum 時間區間:
    String,
    ExpressibleByArgument {

    case 日
    case 月
    case 年
}

extension MyTools {
    struct Random: ParsableCommand {

        @Argument(help: ArgumentHelp(
                    "The value",
                    discussion: "Return a random number",
                    valueName: "random value",
                    shouldDisplay: true))
        var highValue: Int = 100


        func validate() throws {
            guard highValue >= 1 else {
                throw ValidationError(
                    "Value should be at least 1"
                )
            }
        }

        func run() throws {
            print(Int.random(in: 0...highValue))
        }
    }

    struct Pick: ParsableCommand {

        @Argument()
        var element: [String]

        @Option(name: .customLong("c")) // --c <c>
        // @Option(name: [.customShort("C"), .long])
        // -C, --count <count>
        var count: Int = 1

        @Flag(name: .long) // --toggle
        // @Flag(name: .short) // -t
        var toggle: Bool = false

        func run() throws {
            if !toggle {
                let picks = element.shuffled().prefix(count)
                print(picks.joined(separator: "\n"))
            } else {
                print("Hello")
            }
        }
    }

    struct 盤後資訊: ParsableCommand {

        @Argument
        var stockNo: Int

        @Option
        var 時間區間: 時間區間 = .日

        func run() throws {
            var url = ""

            switch 時間區間 {
            case .日:
                url = "https://www.twse.com.tw/exchangeReport/STOCK_DAY?response=json&date=20201105&stockNo=\(stockNo)"
            case .月:
                url = "https://www.twse.com.tw/exchangeReport/FMSRFK?response=json&date=20201107&stockNo=2330"
            case .年:
                url = "https://www.twse.com.tw/exchangeReport/FMNPTK?response=json&stockNo=2330"
            }

            guard let data = QueryService.queryJSON_sync(url: url) else {
                throw ValidationError("")

            }
            guard let dataList = data["data"] as? [[String]],
                  let fields = data["fields"] as? [String]
            else { throw ValidationError("") }

            let results = dataList.map { $0.enumerated().map { fields[$0] + ":" + $1 } }
            results.forEach { print("\($0)\n") }
        }
    }

    struct 每日殖利率: ParsableCommand {
        @Option
        var type: String = "ALL"

        @Argument
        var 殖利率: Double = 0.0

        func run() throws {
            let url = "https://www.twse.com.tw/exchangeReport/BWIBBU_d?response=json&date=20201104&selectType=\(type)"

            guard let data = QueryService.queryJSON_sync(url: url) else {
                throw ValidationError("123")
            }
            guard let dataList = data["data"] as? [[Any]] else {
                throw ValidationError("456")
            }
            guard let fields = data["fields"] as? [String] else {
                throw ValidationError("789")
            }

            let result = dataList.filter { Double($0[2] as? String ?? "") ?? 0 > 殖利率 }.map { $0.enumerated().map { fields[$0] + ":" + "\($1)"} }
            result.forEach { print("\($0[0]), \($0[1]), \($0[2])") }
        }
    }
}

MyTools.main()

import Darwin
import TSCBasic
import TSCUtility
import Foundation

class QueryService {
    typealias JSONDictionary = [String: Any]
}

extension QueryService {
    static let urlSession = URLSession(configuration: .default)

    static func queryJSON_sync(url: String) -> JSONDictionary? {
        guard let url = URL(string: url) else { return nil }
        // Creates new counting semaphore with an initial value.
        let semaphore = DispatchSemaphore(value: 0)

        var dic: JSONDictionary?
        let task = urlSession.dataTask(with: url) { (data, _, _) in
            guard let data = data,
                  let response = try? JSONSerialization.jsonObject(with:
                                                                    data, options: []) as? JSONDictionary else {
                return
            }
            dic = response
            // Increment the counting semaphore
            semaphore.signal()
        }
        task.resume()
        // Decrement the counting semaphore.
        semaphore.wait()

        return dic
    }
}
