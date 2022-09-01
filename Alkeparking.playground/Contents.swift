import UIKit

protocol Parkable {
    var plate: String { get }
    var type: VehicleType { get }
    var checkInTime: Date { get }
    var discountCard: String? { get set }
}

enum VehicleType {
    case car
    case motorcycle
    case miniBus
    case bus
    
    var rate : Int {
        switch self {
        case .car: return 20
        case .motorcycle: return 15
        case.miniBus: return 25
        case .bus: return 30
        }
    }
}

struct Parking {
    var vehicles: Set<Vehicle> = []
    private let maxCars = 20
    var vehiclesProfits = (vehicle: 0, profits: 0)
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool) -> Void) {
        guard vehicles.count < maxCars || vehicles.contains(vehicle)  else {
            return onFinish(false)
        }
        
        let insertedSuccess = vehicles.insert(vehicle).inserted
        return onFinish(insertedSuccess)
    }
    
    private func calculateFee(type: VehicleType, parkedTime: Int, hasDiscount: Bool) -> Int{
        var fee = 0
        
        if parkedTime <= 120 {
            fee = type.rate
        } else {
            fee = type.rate + (getFraction(parkedTime: parkedTime) * 5)
        }
        
        if hasDiscount {
            return Int(Double(fee) - Double(fee) * 0.15)
        }
        return fee
    }
    
    mutating func checkOutVehicle(plate: String, onSuccess: (Int) -> Int, onError:() -> Void) {
        let vehicleExist = vehicles.first(where: {$0.plate == plate})
        guard let vehicle = vehicleExist else {
            onError()
            return
        }
        
        let discountCard = vehicle.discountCard != nil
        let fee = calculateFee(type: vehicle.type, parkedTime: vehicle.parkedTime, hasDiscount: discountCard)
        vehicles.remove(vehicle)
        onSuccess(fee)
        vehiclesProfits.vehicle += 1
        vehiclesProfits.profits += fee
    }
    
    func getProfits(){
        print("\(vehiclesProfits.vehicle) vehicles have checked out and have earnings of $\(vehiclesProfits.profits)")
    }
    
    func getParkedPlates(){
        for vehicle in vehicles {
            print(vehicle.plate)
        }
    }
}

extension Parking {
    private func getFraction(parkedTime: Int) -> Int{
        Int((Double(parkedTime - 120) / 15.0).rounded(.up))
    }
}

struct Vehicle: Parkable, Hashable {
    
    let plate: String
    let type: VehicleType
    let checkInTime = Date()
    var discountCard: String?
    // Se comentó la variable calculado "parkedTime para poder realizar pruebas con el calculo de tarifas"
    /*var parkedTime: Int {
     Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
     }*/
    var parkedTime = 198
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
}

var alkeParking = Parking()

let createdVehicles = [Vehicle(plate: "AA111AA", type: VehicleType.car, discountCard: "DISCOUNT_CARD_001"),
                       Vehicle(plate: "B222BBB", type: VehicleType.motorcycle, discountCard: nil),
                       Vehicle(plate: "CC333CC", type: VehicleType.miniBus, discountCard: nil),
                       Vehicle(plate: "DD444DD", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_002"),
                       Vehicle(plate: "AA111BB", type: VehicleType.car, discountCard: "DISCOUNT_CARD_003"),
                       Vehicle(plate: "B222CCC", type: VehicleType.motorcycle, discountCard: "DISCOUNT_CARD_004"),
                       Vehicle(plate: "CC333DD", type: VehicleType.miniBus, discountCard: nil),
                       Vehicle(plate: "DD444EE", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_005"),
                       Vehicle(plate: "AA111CC", type: VehicleType.car, discountCard: nil),
                       Vehicle(plate: "B222DDD", type: VehicleType.motorcycle, discountCard: nil),
                       Vehicle(plate: "CC333EE", type: VehicleType.miniBus, discountCard: nil),
                       Vehicle(plate: "DD444GG", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_006"),
                       Vehicle(plate: "AA111DD", type: VehicleType.car, discountCard: "DISCOUNT_CARD_007"),
                       Vehicle(plate: "B222EEE", type: VehicleType.motorcycle, discountCard: nil),
                       Vehicle(plate: "CC333FF", type: VehicleType.miniBus, discountCard: nil),
                       Vehicle(plate: "AA111DA", type: VehicleType.car, discountCard: "DISCOUNT_CARD_008"),
                       Vehicle(plate: "AA111DS", type: VehicleType.car, discountCard: nil),
                       Vehicle(plate: "AA111DF", type: VehicleType.car, discountCard: "DISCOUNT_CARD_009"),
                       Vehicle(plate: "AA111DR", type: VehicleType.car, discountCard: nil),
                       Vehicle(plate: "AA111DY", type: VehicleType.car,  discountCard: nil),
                       Vehicle(plate: "AA11SDY", type: VehicleType.car,  discountCard: nil)]

for vehicle in createdVehicles {
    alkeParking.checkInVehicle(vehicle) { result in
        result ? print("Welcome to Alkeparking") : print("Sorry, the check-in failed")
    }
}

alkeParking.checkOutVehicle(plate: createdVehicles[0].plate) { fee in
    print("Your fee is $\(fee). Come back soon")
    return fee
} onError: {
    print("Sorry, the check-out failed")
}

alkeParking.checkOutVehicle(plate: createdVehicles[8].plate) { fee in
    print("Your fee is $\(fee). Come back soon")
    return fee
} onError: {
    print("Sorry, the check-out failed")
}

alkeParking.getProfits()
alkeParking.getParkedPlates()



