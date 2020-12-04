import UIKit
import SwiftUI

extension EnvironmentObject {
    var hasValue: Bool {
        Mirror(reflecting: self).children.contains { ($0.value is ObjectType) }
    }
}

class ViewSwap<S>: ObservableObject where S: View, S: Swappable {

    init<V>(with customView: @escaping (S.InputType) -> V, insteadOf _: S.Type)
    where V: View {
        self.view = { AnyView(customView($0)) }
    }

    let view: (S.InputType) -> AnyView
}

struct SwappedIfNeeded<S>: View where S: View, S: Swappable {

    @EnvironmentObject var swap: ViewSwap<S>

    let input: S.InputType
    let content: S.DefaultBody

    init(input: S.InputType, content: S.DefaultBody) {
        self.input = input
        self.content = content
    }

    var body: some View {
        Group {
            if _swap.hasValue {
                swap.view(input)
            } else {
                content
            }
        }
    }
}


public protocol Swappable {

    associatedtype InputType
    var input: InputType { get }
    init(input: InputType)

    associatedtype DefaultBody : View
    @ViewBuilder var defaultBody: DefaultBody { get }
}

public extension View {

    func swapView<V, S>(_ initV : @escaping (S.InputType) -> V, insteadOf typeS: S.Type) -> some View
    where S: View, S: Swappable,
          V: View {
        environmentObject(ViewSwap<S>(with: initV, insteadOf: typeS))
    }

    @available(*, unavailable, message: "Init parameters must match!")
    func swapView<V, S, P>(_ initV : (P) -> V, insteadOf typeS: S.Type) -> some View
    where S: View, S: Swappable,
          V: View {
        self
    }
}

extension Swappable where Self: View {

    var body: some View {
        SwappedIfNeeded<Self>(input: input, content: defaultBody)
    }
}
