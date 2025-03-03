import 'package:flutter/material.dart';
import 'image_gallery.dart';

class ServicePostViewWidget extends StatelessWidget {
  const ServicePostViewWidget({
    super.key, String? postId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 5),
      child: Expanded(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -20,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 1, 0, 10),
                child: Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(242, 195, 27, 0.862),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'ذهبي',
                    style: TextStyle(
                      color: Color.fromARGB(255, 11, 11, 11),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    height: 45,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 254, 255, 254),
                          radius: 20,
                          child: CircleAvatar(
                            backgroundImage: AssetImage('assets/avatar.png'),
                            radius: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Nidal Abd',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '2 hours ago',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 70),
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'مطلوب موظفة ملتميديا',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'مطلوب موظفة ملتميديا\nالمهام الوظيفية والشروط\nلديها القدرة على تصوير الفيديو والفوتو\nمتمكن من العمل على برامج ادوبي وخاصة فوتوشوب، بريمير، افترافكت\nتصميم الاعلانات والبروشورات\nأن يكون من القدرة على تحمل ضغط العمل وعدد التصاميم والعمل بروح الفريق\nمن يجد في نفسه الخبرة الكافية الرجاء ارسال الاعمال على واتس اب',
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: 16),
                        ),
                        Column(
                          children: const [
                            ImageGallery(
                              imageUrls: [
                                'https://picsum.photos/600/300?random=1',
                                'https://picsum.photos/600/300?random=2',
                                'https://picsum.photos/600/300?random=3',
                                'https://picsum.photos/600/300?random=4',
                                'https://picsum.photos/600/300?random=5',
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone),
                              label: const Text('Whatsapp'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone),
                              label: const Text('phone'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.email),
                              label: const Text('email'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                fixedSize: WidgetStateProperty.all(
                                    Size.fromWidth(
                                        MediaQuery.of(context).size.width /
                                            1.17)),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.person_add),
                              label: const Text('اضافة لجهات الاتصال'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 40,
                    color: const Color.fromARGB(14, 148, 180, 248),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.remove_red_eye, size: 16),
                            SizedBox(width: 5),
                            Text('10', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(Icons.favorite_border, size: 16),
                            SizedBox(width: 5),
                            Text('5', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -22,
              right: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 1, 0, 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 237, 237, 233),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'وظيفة',
                    style: TextStyle(
                        color: Color.fromARGB(255, 11, 11, 11), fontSize: 10),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -22,
              right: 50,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 1, 0, 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 237, 237, 233),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'برمجة',
                    style: TextStyle(
                        color: Color.fromARGB(255, 11, 11, 11), fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
