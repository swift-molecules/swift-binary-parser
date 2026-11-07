public import Binary


extension Binary.Parse.Validated {
    public enum Error: Swift::Error {

        case endOfInput(expected: String)

        case invalid(rawValue: T.RawValue)
    }
}
