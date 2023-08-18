import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../providers/places_provider.dart';
import '../screens/place_screen.dart';
import '../models/place.dart';

class PlaceItem extends ConsumerStatefulWidget {
  const PlaceItem(this.place, {super.key});
  final Place place;

  @override
  ConsumerState<PlaceItem> createState() => _PlaceItemState();
}

class _PlaceItemState extends ConsumerState<PlaceItem> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => ref.read(placesProvider.notifier).removePlace(widget.place),
      key: ValueKey(widget.place.id),
      background: ColoredBox(
        color: colorScheme.error,
        child: const Row(
          children: [
            SizedBox(width: 16),
            Icon(
              Icons.delete,
              size: 40,
            ),
            Spacer(),
          ],
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlaceScreen(widget.place))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32),
                  ),
                  border: Border.all(
                    width: 1,
                    color: colorScheme.primary,
                  ),
                  image: DecorationImage(
                    image: FileImage(
                      widget.place.image,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.place.location.address!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.secondary),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
