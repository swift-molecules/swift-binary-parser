public import Binary


extension Binary.Parse.Converting {
    public enum Error: Swift::Error {

        case endOfInput(expected: String)

        case overflow(source: Source)
    }
}
