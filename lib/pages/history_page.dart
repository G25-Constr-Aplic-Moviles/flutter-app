import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/viewmodels/history_viewmodel.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final historyViewModel = Provider.of<HistoryViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
        title: const Text(
          'History',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (historyViewModel.isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (historyViewModel.history.isEmpty)
              const Center(
                child: Text(
                  'No history records available.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: historyViewModel.history.length,
                  itemBuilder: (context, index) {
                    final item = historyViewModel.history[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            '${item.restaurantName} - ${item.date}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (index != historyViewModel.history.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(
                              color: Colors.grey,
                              height: 1.0,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
