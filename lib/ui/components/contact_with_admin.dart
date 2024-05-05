import 'package:flutter/cupertino.dart';

class ContactWithAdmin extends StatelessWidget {
  const ContactWithAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/not_active.png' , scale: 3,),
          const SizedBox(height: 8,) ,
          const Text('Please Contact with admin'),
        ],
      ),
    );
  }
}