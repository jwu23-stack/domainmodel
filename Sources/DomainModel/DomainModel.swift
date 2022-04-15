struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount : Int
    var currency: String
    
    init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
    
    func convert(_ convertTo: String) -> Money {
        var totalUSDAmount = 0
        var convertedAmount = 0
        switch self.currency { // normalize all currency types to USD
        case "GBP":
            totalUSDAmount = self.amount * 2
        case "EUR":
            totalUSDAmount = Int(Double(self.amount) / 1.5)
        case "CAN":
            totalUSDAmount = Int(Double(self.amount) / 1.25)
        default:
            totalUSDAmount = self.amount
        }
        switch convertTo { // convert USD to specified currency name
        case "GBP":
            convertedAmount = totalUSDAmount / 2
        case "EUR":
            convertedAmount = Int(Double(totalUSDAmount) * 1.5)
        case "CAN":
            convertedAmount = Int(Double(totalUSDAmount) * 1.25)
        default:
            convertedAmount = totalUSDAmount
        }
        return Money(amount: convertedAmount, currency: convertTo)
    }
    
    func add(_ otherAmount: Money) -> Money {
        let convertedAmount = convert(otherAmount.currency).amount
        return Money(amount: (convertedAmount + otherAmount.amount), currency: otherAmount.currency)
    }
    
    func subtract(_ otherAmount: Money) -> Money {
        let convertedAmount = convert(otherAmount.currency).amount
        return Money(amount: (convertedAmount - otherAmount.amount), currency: otherAmount.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    var title : String
    var type: JobType
    
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ hours: Int) -> Int {
        switch self.type {
        case .Salary(let salary):
            return Int(salary)
        case .Hourly(let hourly):
            return Int(hourly * Double(hours))
        }
    }
    
    func raise(byAmount: Int) -> Void {
        switch self.type {
        case .Salary(let salary):
            self.type = .Salary(UInt(Int(salary) + byAmount))
        case .Hourly(let hourly):
            self.type = .Hourly(Double(Int(hourly) + byAmount))
        }
    }
    
    func raise(byAmount: Double) -> Void {
        switch self.type {
        case .Salary(let salary):
            self.type = .Salary(UInt(Double(salary) + byAmount))
        case .Hourly(let hourly):
            self.type = .Hourly(hourly + byAmount)
        }
    }
    
    func raise(byPercent: Double) {
        switch self.type {
        case .Salary(let salary):
            self.type = .Salary(UInt(Double(salary) * (1.0 + byPercent)))
        case .Hourly(let hourly):
            self.type = .Hourly((hourly) * (1.0 + byPercent))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    var firstName: String
    var lastName: String
    var age: Int
    var job: Job? {
        didSet{
            if age < 16 {
                job = nil
            }
        }
    }
    var spouse: Person? {
        didSet{
            if age < 18 {
               spouse = nil
            }
        }
    }
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    func toString() -> String {
        var jobString : String = ""
        var spouseString : String = ""
        if let job = self.job {
            jobString = "\(job.title) with \(job.type) pay"
        } else {
           jobString = "nil"
        }
        if let spouse = self.spouse {
            spouseString = "\(spouse.firstName)"
        } else {
            spouseString = "nil"
        }
        return "[Person: firstName:\(self.firstName) lastName:\(self.lastName) age:\(self.age) job:\(jobString) spouse:\(spouseString)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    var members : [Person] = []
    
    init(spouse1: Person, spouse2: Person) {
        if spouse1.spouse == nil && spouse2.spouse == nil {
            spouse1.spouse = spouse2
            spouse2.spouse = spouse1
            members.append(contentsOf: [spouse1, spouse2])
        } else { // either person already have a spouse
            members = []
        }
    }
    
    func haveChild(_ child: Person) -> Bool {
        for member in self.members {
            if member.age > 21 {
                members.append(child)
                return true
            }
        }
        return false
    }
    
    func householdIncome() -> Int {
        var total : Int = 0
        for member in self.members {
            let income = member.job?.calculateIncome(2000) ?? 0
            total += income
        }
        return total
    }
}
