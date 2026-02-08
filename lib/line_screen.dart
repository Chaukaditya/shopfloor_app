import 'package:flutter/material.dart';
import 'document_screen.dart';

class LineScreen extends StatelessWidget {
  const LineScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Production lines list
    final List<String> lines = [
      "1. W502 Head Lamp Assembly Line",
      "2. Nexon FFL Assembly Line",
      "3. Z101 FFL Assembly Line",
      "4. Nova Assembly Line",
      "5. MRS Head Lamp Assembly Line",
      "6. Punch Head Lamp Assembly Line",
      "7. W616 FFL Assembly Line",
      "8. W616 Corning Lamp Assembly Line",
      "9. Z101 Head Lamp HV Assembly Line",
      "10. Z101 Head Lamp BV Assembly Line",
      "11. Z101 RFL Assembly Line",
      "12. Z101 HMSL Assembly Line",
      "13. M110 Head Lamp Assembly Line",
      "14. M110 Top DRL Assembly Line",
      "15. M110 Bottom DRL Assembly Line",
      "16. Altroz TGL Assembly Line",
      "17. Altroz BSO Assembly Line",
      "18. Punch DRL Assembly Line",
      "19. SK216 Kylaq Assembly Line",
      "20. M310 HMSL Assembly Line",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Select Production Line")),
      body: ListView.builder(
        itemCount: lines.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(lines[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentScreen(
                    lineName: lines[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
