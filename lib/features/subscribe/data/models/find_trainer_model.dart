class FindTrainerModel {
  final String? title;
  final String? subtitle;
  final double? price;
  final String? image;

  FindTrainerModel({
     this.title,
     this.price, this.subtitle, this.image,
  });

static  final List<FindTrainerModel> trainers = [
  FindTrainerModel(
      title: 'Oliver Kingsley',
      price: 50.00,
    image: '',
    subtitle: 'Specialist in transformation'
    ),
  FindTrainerModel(
      title: 'Oliver Kingsley',
      price: 19.99,
      image: '',
      subtitle: 'Specialist in transformation'
    ),
  ];
}