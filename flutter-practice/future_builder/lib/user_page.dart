import 'package:flutter/material.dart';
import 'package:future_builder/user.dart';

class UserPage extends StatelessWidget {
  UserPage({super.key});

  final Future<String> _fetch =
      Future.delayed(const Duration(seconds: 2), () => "SOME THING");
  final Future<String> _fetchError =
      Future.delayed(const Duration(seconds: 2), () {
    throw Exception('ERROR OCCUR');
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('User Page'),
        ),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FutureBuilder(
                    future: _fetchError,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                'Hello ${UserDataLayer.of(context).user?.name}'),
                            const SizedBox(height: 10),
                            Text('${snapshot.data}')
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text('Error: ${snapshot.error}'),
                              ),
                            ]);
                      }
                      return const CircularProgressIndicator();
                    }))));
  }
}
