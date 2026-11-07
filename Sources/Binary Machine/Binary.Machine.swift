public import Binary
public import Machine
public import Byte
public import Checkpoint
import Index
import Tagged

extension Binary {

    public enum Machine {}
}

extension Binary.Machine {

    public typealias Value = Machine::Machine.Value<Mode>

    public typealias Transform = Machine::Machine.Transform

    public typealias Combine = Machine::Machine.Combine

    public typealias Finalize = Machine::Machine.Finalize

    public typealias Next = Machine::Machine.Next
}

extension Binary.Machine {

    public typealias Checkpoint = ArraySlice<Byte>.Checkpoint

    public typealias Frame<Position> = Machine::Machine.Frame<
        Node.ID, Position, Mode, Fault, Never
    >
}

extension Binary.Machine {

    public typealias Node = Machine::Machine.Node<Instruction, Fault, Mode>
}

extension Binary.Machine {

    @inlinable
    public static func u8Parser() -> Parser<UInt8> {
        build { u8(in: &$0) }
    }

    @inlinable
    public static func u16leParser() -> Parser<UInt16> {
        build { u16le(in: &$0) }
    }

    @inlinable
    public static func u16beParser() -> Parser<UInt16> {
        build { u16be(in: &$0) }
    }

    @inlinable
    public static func u32leParser() -> Parser<UInt32> {
        build { u32le(in: &$0) }
    }

    @inlinable
    public static func u32beParser() -> Parser<UInt32> {
        build { u32be(in: &$0) }
    }

    @inlinable
    public static func u64leParser() -> Parser<UInt64> {
        build { u64le(in: &$0) }
    }

    @inlinable
    public static func u64beParser() -> Parser<UInt64> {
        build { u64be(in: &$0) }
    }

    @inlinable
    public static func i8Parser() -> Parser<Int8> {
        build { i8(in: &$0) }
    }

    @inlinable
    public static func i16leParser() -> Parser<Int16> {
        build { i16le(in: &$0) }
    }

    @inlinable
    public static func i16beParser() -> Parser<Int16> {
        build { i16be(in: &$0) }
    }

    @inlinable
    public static func i32leParser() -> Parser<Int32> {
        build { i32le(in: &$0) }
    }

    @inlinable
    public static func i32beParser() -> Parser<Int32> {
        build { i32be(in: &$0) }
    }

    @inlinable
    public static func i64leParser() -> Parser<Int64> {
        build { i64le(in: &$0) }
    }

    @inlinable
    public static func i64beParser() -> Parser<Int64> {
        build { i64be(in: &$0) }
    }

    @inlinable
    public static func uleb128Parser() -> Parser<UInt64> {
        build { uleb128(in: &$0) }
    }

    @inlinable
    public static func sleb128Parser() -> Parser<Int64> {
        build { sleb128(in: &$0) }
    }
}

extension Binary.Machine {

    public typealias Program = Machine::Machine.Program<Instruction, Fault, Mode>
}
