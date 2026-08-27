public import Machine
import Tagged

extension Binary.Machine {

    public typealias Node = Machine.Machine.Node<Instruction, Fault, Mode>
}
