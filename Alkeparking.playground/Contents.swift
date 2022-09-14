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

enum CheckinStatus {
    case parkingFull
    case vehicleAlreadyRegistered
    case success
    
    var loclizedDescription: String {
        switch self {
        case .parkingFull: return "Sorry,the check-in failed: parking full"
        case .vehicleAlreadyRegistered: return "Sorry, the check-in failed: vehicle already registered"
        case .success: return "Welcome to Alkeparking"
        }
    }
}

struct Parking {
    private (set) var vehicles: Set<Vehicle> = []
    private let maxCars = 20
    private (set) var vehiclesProfits = (vehicle: 0, profits: 0)
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (CheckinStatus) -> Void) {
        guard hasParkingPlace() else {
            return onFinish(CheckinStatus.parkingFull)
        }
        
        guard !vehicleHasAlreadyRegistered(vehicle) else {
            return onFinish(CheckinStatus.vehicleAlreadyRegistered)
        }
        
        vehicles.insert(vehicle).inserted
        onFinish(CheckinStatus.success)
    }
    
    private func calculateFee(type: VehicleType, parkedTime: Int, hasDiscount: Bool) -> Int{
        var fee = 0
        let baseFee = type.rate
        
        if parkedTime > 120{
            fee = baseFee + getFractionFee(parkedTime)
        } else {
            fee = baseFee
        }
        
        if hasDiscount{
            fee = Int(Double(fee) * 0.85)
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
        vehicles.forEach { vehicle in
            print(vehicle.plate)
        }
    }
}

extension Parking {
    private func getFractionFee(_ parkedTime: Int) -> Int{
        Int((Double(parkedTime - 120) / 15.0).rounded(.up) * 5)
    }
    
    private func hasParkingPlace() -> Bool{
        vehicles.count <= maxCars
    }
    
    private func vehicleHasAlreadyRegistered(_ vehicle: Vehicle) -> Bool {
        vehicles.contains(vehicle)
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
    var parkedTime = 100
    
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
                       Vehicle(plate: "AA11SDY", type: VehicleType.car,  discountCard: nil),
                       Vehicle(plate: "AA11SJDY", type: VehicleType.car,  discountCard: nil)]

createdVehicles.forEach { vehicle in
    alkeParking.checkInVehicle(vehicle) { result in
        print("\(result.loclizedDescription), plate: \(vehicle.plate)")
    }
}

alkeParking.checkOutVehicle(plate: createdVehicles[0].plate) { fee in
    print("Your fee is $\(fee), parking time: \(createdVehicles[0].parkedTime). Come back soon")
    return fee
} onError: {
    print("Sorry, the check-out failed")
}

alkeParking.checkOutVehicle(plate: createdVehicles[8].plate) { fee in
    print("Your fee is $\(fee), parking time: \(createdVehicles[0].parkedTime). Come back soon")
    return fee
} onError: {
    print("Sorry, the check-out failed")
}

alkeParking.getProfits()
alkeParking.getParkedPlates()
