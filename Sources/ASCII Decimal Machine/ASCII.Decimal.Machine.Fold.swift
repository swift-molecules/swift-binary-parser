internal import ASCII
internal import Binary_Machine

extension ASCII.Decimal.Machine {

    struct Fold<U: FixedWidthInteger & UnsignedInteger> {
        var multiplier: U = 1
        var sum: U = 0
        var multiplierOverflow = false
        var sumOverflow = false

        func appending(_ digit: U) -> Self {
            let power = multiplier.multipliedReportingOverflow(by: 10)
            let scaled = sum.multipliedReportingOverflow(by: 10)
            let accumulated = scaled.partialValue.addingReportingOverflow(digit)
            return Self(
                multiplier: power.partialValue,
                sum: accumulated.partialValue,
                multiplierOverflow: multiplierOverflow || power.overflow,
                sumOverflow: sumOverflow || scaled.overflow || accumulated.overflow
            )
        }

        func value(prepending first: U) throws(Binary.Machine.Fault) -> U {
            guard !sumOverflow, first == 0 || !multiplierOverflow else { throw .outOfRange }
            let prefix = first.multipliedReportingOverflow(by: multiplier)
            let total = prefix.partialValue.addingReportingOverflow(sum)
            guard !prefix.overflow, !total.overflow else { throw .outOfRange }
            return total.partialValue
        }
    }
}
