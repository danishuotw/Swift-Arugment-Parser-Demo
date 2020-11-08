import ArgumentParser

struct DemoMyTools: ParsableCommand {
    static let configuration =
        CommandConfiguration(subcommands: [
                                Random.self,
                                每日殖利率.self])
}

extension DemoMyTools {
    struct Random: ParsableCommand {

        @Argument(help: ArgumentHelp("iPlayground 好棒棒",
                                     discussion: "discussion",
                                     valueName: "valueName",
                                     shouldDisplay: true))
        var value: Int = 100

        func run() throws {
            print(Int.random(in: 0...value))
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


DemoMyTools.main()


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
        let animation = PercentProgressAnimation(
          stream: stdoutStream,
          header: "Loading Awesome Stuff ✨")

        for i in 0..<100 {
          let second: Double = 1_000_000
          usleep(UInt32(second * 0.05))
          animation.update(step: i, total: 100, text: "Loading..")
        }

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
            
            animation.complete(success: true)
            print("Done! 🚀")
        }
        task.resume()
        // Decrement the counting semaphore.
        semaphore.wait()

        return dic
    }
}

let animation = PercentProgressAnimation(
  stream: stdoutStream,
  header: "Loading Awesome Stuff ✨")

for i in 0..<100 {
  let second: Double = 1_000_000
  usleep(UInt32(second * 0.05))
  animation.update(step: i, total: 100, text: "Loading..")
}

animation.complete(success: true)
print("Done! 🚀")
