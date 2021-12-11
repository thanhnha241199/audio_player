class SongModel {
  String? url;
  String? name;
  String? singer;
  String? image;

  SongModel({
    this.url,
    this.name,
    this.singer,
    this.image,
  });

  SongModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    name = json['name'];
    singer = json['singer'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['name'] = name;
    data['singer'] = singer;
    data['image'] = image;
    return data;
  }
}
