public import Binary
import Byte
import Cardinal
import Cursor
import Ordinal

extension RawRepresentable where RawValue: FixedWidthInteger {

    public static var parser: Binary.Parser<Self> {
        Binary.Parser { input throws(Binary.Machine.Fault) in
            let size = MemoryLayout<RawValue>.size
            guard input.count >= size else {
                throw .insufficientBytes(
                    need: Index<Byte>.Count(Cardinal(UInt(size))),
                    have: Index<Byte>.Count(Cardinal(UInt(input.count)))
                )
            }
            let bytes = Array(input.prefix(size))
            input.removeFirst(size)
            guard let raw = RawValue(bytes: bytes, endianness: .little) else {
                throw .malformed
            }
            guard let value = Self(rawValue: raw) else {
                throw .outOfRange
            }
            return value
        }
    }
}
