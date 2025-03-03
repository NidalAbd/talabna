import 'package:flutter/material.dart';

class ServicePostWidget extends StatelessWidget {
  const ServicePostWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(


      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 2, 0),
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
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      color: const Color.fromARGB(255, 224, 224, 224),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color.fromARGB(238, 249, 230, 248),
                          radius: 16,
                          child: CircleAvatar(
                            backgroundImage: AssetImage('assets/avatar.png'),
                            radius: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Nidal.Abd',
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
                  const Divider(
                    height: 0,
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        SizedBox(height: 10),
                        Text(
                          'مطلوب موظفة ملتميديا\nالمهام الوظيفية والشروط\nلديها القدرة على تصوير الفيديو والفوتو\nمتمكن من العمل على برامج ادوبي وخاصة فوتوشوب، بريمير، افترافكت\nتصميم الاعلانات والبروشورات\nأن يكون من القدرة على تحمل ضغط العمل وعدد التصاميم والعمل بروح الفريق\nمن يجد في نفسه الخبرة الكافية الرجاء ارسال الاعمال على واتس اب',
                          textAlign: TextAlign.justify,
                          maxLines: 6,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 40,
                    color: const Color.fromARGB(255, 253, 250, 250),
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
                        IconButton(
                          onPressed: () {
                            // Navigate to detail page
                          },
                          icon: const Icon(Icons.arrow_forward_sharp),
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
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
