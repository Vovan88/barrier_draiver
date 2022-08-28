import 'package:barrier_drive/models/userdata.dart';
import 'package:barrier_drive/services/service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {
  final String token;
  const UserWidget({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: getUser(token),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CachedNetworkImage(
                    httpHeaders: {"login": user.login, "token": token},
                    cacheKey: user.login,
                    imageUrl: "$address/getavatars",
                    progressIndicatorBuilder: (context, url, progress) {
                      return const Center(child: CircularProgressIndicator());
                    },
                    imageBuilder: (context, imageProvider) {
                      return CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 6,
                        backgroundImage: imageProvider,
                      );
                    },
                  ),
                ),
              ),
              Text(user.login)
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
