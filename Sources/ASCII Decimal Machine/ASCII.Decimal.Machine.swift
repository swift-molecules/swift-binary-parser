public import Binary
public import ASCII
public import Binary_Machine
internal import Byte

extension ASCII.Decimal {
    public enum Machine {}
}

extension ASCII.Decimal.Machine {
    public static func unsigned<T: UnsignedInteger & FixedWidthInteger & Sendable>(
        _ type: T.Type = T.self
    ) -> Binary.Machine.Parser<T> {
        Binary.Machine.build { builder in
            magnitude(T.self, in: &builder)
        }
    }

    public static func signed<T: SignedInteger & FixedWidthInteger & Sendable>(
        _ type: T.Type = T.self
    ) -> Binary.Machine.Parser<T> {
        Binary.Machine.build { builder in
            let minus = Binary.Machine.byte(Byte(bitPattern: 0x2D), in: &builder).map({ _ in true }, in: &builder)
            let plus = Binary.Machine.byte(Byte(bitPattern: 0x2B), in: &builder).map({ _ in false }, in: &builder)
            let absent = Binary.Machine.pure(false, in: &builder)
            let negative = Binary.Machine.oneOf([minus, plus, absent], in: &builder)
            let digits = magnitude(T.Magnitude.self, in: &builder)
            let signedMagnitude = Binary.Machine.sequence(
                negative, digits, combine: { ($0, $1) }, in: &builder
            )
            return signedMagnitude.tryMap(
                { pair throws(Binary.Machine.Fault) -> T in
                    let (negative, magnitude) = pair
                    if negative, magnitude == T.min.magnitude { return T.min }
                    guard let value = T(exactly: magnitude) else { throw .outOfRange }
                    return negative ? -value : value
                },
                in: &builder
            )
        }
    }

    private static func magnitude<U: FixedWidthInteger & UnsignedInteger>(
        _ type: U.Type, in builder: inout Binary.Machine.Builder
    ) -> Binary.Machine.Expression<U> {
        let digit = Binary.Machine.take1(in: &builder).tryMap(
            { byte throws(Binary.Machine.Fault) -> U in
                let code = byte.bitPattern
                guard (0x30...0x39).contains(code) else { throw .predicateFailed(byte: byte) }
                return U(code - 0x30)
            },
            in: &builder
        )
        let suffix = Binary.Machine.fold(
            digit, initial: Fold<U>(), combine: { $0.appending($1) }, in: &builder
        )
        let number = Binary.Machine.sequence(
            digit, suffix, combine: { ($0, $1) }, in: &builder
        )

        return number.tryMap(
            { pair throws(Binary.Machine.Fault) -> U in
                try pair.1.value(prepending: pair.0)
            },
            in: &builder
        )
    }
}
