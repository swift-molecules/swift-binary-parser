public import Binary
public import Machine

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
