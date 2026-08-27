public import Machine
import Tagged

extension Binary.Machine {

    public typealias Program = Machine.Machine.Program<Instruction, Fault, Mode>
}
