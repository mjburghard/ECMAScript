//
//  Created by Manuel Burghard. Licensed unter MIT.
//

import JavaScriptKit

public class Promise<Type>: JSBridgedType {

    public let objectRef: JSObjectRef

    public required init(objectRef: JSObjectRef) {

        self.objectRef = objectRef
    }
}

public class ReadableStream: JSBridgedType {

    public let objectRef: JSObjectRef

    public required init(objectRef: JSObjectRef) {
        self.objectRef = objectRef
    }

    public subscript(dynamicMember name: String) -> JSValue {
        get { objectRef[dynamicMember: name] }
        set { objectRef[dynamicMember: name] = newValue }
    }
}

@propertyWrapper public struct ClosureHandler<ArgumentType: JSValueEncodable & JSValueDecodable, ReturnType: JSValueEncodable & JSValueDecodable> {

    let objectRef: JSObjectRef
    let name: String

    public init(objectRef: JSObjectRef, name: String) {
        self.objectRef = objectRef
        self.name = name
    }

    public var wrappedValue: (ArgumentType) -> ReturnType {
        get {
            let function: JSFunctionRef = objectRef[dynamicMember: name]
            return function.wrappedClosure()
        }
        set {
            objectRef[dynamicMember: name] = JSFunctionRef.from(newValue).jsValue()
        }
    }
}

@propertyWrapper public struct OptionalClosureHandler<ArgumentType: JSValueEncodable & JSValueDecodable, ReturnType: JSValueEncodable & JSValueDecodable> {

    let objectRef: JSObjectRef
    let name: String

    public init(objectRef: JSObjectRef, name: String) {
        self.objectRef = objectRef
        self.name = name
    }

    public var wrappedValue: ((ArgumentType) -> ReturnType)? {
        get {
            guard let function: JSFunctionRef = objectRef[dynamicMember: name] else {
                return nil
            }
            return function.wrappedClosure()
        }
        set {
            if let newValue = newValue {
                objectRef[dynamicMember: name] = JSFunctionRef.from(newValue).jsValue()
            } else {
                objectRef[dynamicMember: name] = .null
            }
        }
    }
}

@propertyWrapper public struct ReadWriteAttribute<Wrapped: JSValueEncodable & JSValueDecodable> {

    let objectRef: JSObjectRef
    let name: String

    public init(objectRef: JSObjectRef, name: String) {
        self.objectRef = objectRef
        self.name = name
    }

    public var wrappedValue: Wrapped {
        get {
            return objectRef[dynamicMember: name]
        }
        set {
            objectRef[dynamicMember: name] = newValue
        }
    }
}

@propertyWrapper public struct ReadonlyAttribute<Wrapped: JSValueDecodable> {

    let objectRef: JSObjectRef
    let name: String

    public init(objectRef: JSObjectRef, name: String) {
        self.objectRef = objectRef
        self.name = name
    }

    public var wrappedValue: Wrapped {
        get {
            return objectRef[dynamicMember: name].fromJSValue()
        }
    }
}

public class ValueIterableIterator<SequenceType: JSBridgedType & Sequence>: IteratorProtocol where SequenceType.Element: JSValueDecodable {

    private var index: Int = 0
    private let sequence: SequenceType

    public init(sequence: SequenceType) {
        self.sequence = sequence
    }

    public func next() -> SequenceType.Element? {
        defer {
            index += 1
        }
        let value = sequence.objectRef[index]
        guard value != .undefined else {
            return nil
        }

        return value.fromJSValue()
    }
}

public protocol KeyValueSequence: Sequence where Element == (String, Value) {
    associatedtype Value
}

public class PairIterableIterator<SequenceType: JSBridgedType & KeyValueSequence>: IteratorProtocol where SequenceType.Value: JSValueDecodable {

    private let iterator: JSObjectRef
    private let sequence: SequenceType

    public init(sequence: SequenceType) {
        self.sequence = sequence
        self.iterator = sequence.objectRef.entries!().object!
    }

    public func next() -> SequenceType.Element? {

        let next: JSObjectRef = iterator.next!().object!

        guard next[dynamicMember: "done"].boolean! == false else {
            return nil
        }

        let keyValue: [AnyJSValueCodable] = next[dynamicMember: "value"].fromJSValue()
        return (keyValue[0].fromJSValue(), keyValue[1].fromJSValue())
    }
}
