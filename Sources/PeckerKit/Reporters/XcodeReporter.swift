import Foundation
import SwiftSyntax

public struct XcodeReporter: Reporter {
    public func report(_ configuration: Configuration, sources: [SourceDetail]) {
        for source in sources {
            print("\(source.name): warning: Pecker: The file was never used; consider removing it")
        }
    }
}
