import 'dart:math';

import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/utils/app_state.dart';
import 'package:easy_location/design_system/easy_location_strings.dart';
import 'package:easy_location/modules/location/domain/params/get_location_params.dart';
import 'package:easy_location/modules/location/presenter/events/location_events.dart';
import 'package:easy_location/modules/location/presenter/store/get_location_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class LatLngToScreenPointPage extends StatefulWidget {
  const LatLngToScreenPointPage({
    super.key,
    required this.locationStore,
  });

  final GetLocationStore locationStore;

  @override
  State<LatLngToScreenPointPage> createState() => _LatLngToScreenPointPageState();
}

class _LatLngToScreenPointPageState extends State<LatLngToScreenPointPage> {
  late final MapController mapController;

  LatLng? tappedCoords;
  Point<double>? tappedPoint;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    widget.locationStore.add(
      const GetLocationEvent(
        GetLocationParams(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          EasyLocationStrings.title,
          style: TextStyle(
            fontSize: 24,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
        ),
      ),
      body: BlocBuilder<GetLocationStore, AppState<LatLngDto>>(
        bloc: widget.locationStore,
        builder: (context, state) {
          return state.when(
            success: (geolocation) {
              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    geolocation.lat,
                    geolocation.lng,
                  ),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: ~InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: EasyLocationStrings.urlTemplate,
                    userAgentPackageName: EasyLocationStrings.userAgentPackageName,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: screenSize.width * 0.1,
                        height: screenSize.width * 0.1,
                        point: LatLng(
                          geolocation.lat,
                          geolocation.lng,
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: screenSize.width * 0.1,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ),
                ],
              );
            },
            idle: () {
              return const SizedBox.shrink();
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            error: (error) {
              return Center(
                child: Text(
                  EasyLocationStrings.locationError,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: GoogleFonts.inter().fontFamily,
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
