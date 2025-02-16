class ParkingSpot {
  int id;
  String name;
  String address;
  int totalSpots;
  int occupiedSpots;
  String imageUrl;
  int costPerHour;
  String owner;

  ParkingSpot({
    required this.id,
    required this.name,
    required this.address,
    this.totalSpots = 0,
    this.occupiedSpots = 0,
    this.imageUrl = "",  // Default empty string
    this.costPerHour = 0,  // Default cost
    this.owner = "",  // Default empty string
  });
}
