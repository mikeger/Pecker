import Foundation
import SwiftSyntax

public struct XcodeReporter: Reporter {
    
    public func report(_ configuration: Configuration, sources: [SourceDetail]) {
        fatalError("What should I do?")
//        let diagnosticEngine = makeDiagnosticEngine()
//        for source in sources {
//            let message = Diagnostic.Message(.warning, "Pecker: \(source.name) was never used; consider removing it")
//            diagnosticEngine.diagnose(message, location: source.location.ssLocation, actions: nil)
//        }
    }
}
//
///// Makes and returns a new configured diagnostic engine.
//private func makeDiagnosticEngine() -> DiagnosticEngine {
//  let engine = DiagnosticEngine()
//  let consumer = PrintingDiagnosticConsumer()
//  engine.addConsumer(consumer)
//  return engine
//}
