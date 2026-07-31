import 'package:flutter/material.dart';
import '../services/transport_service.dart';

class DirectionDetailsScreen extends StatefulWidget {
  final String vehicleJourneyId;
  final String directionName;
  final Color color;
  final Color textColor;

  const DirectionDetailsScreen({
    super.key,
    required this.vehicleJourneyId,
    required this.directionName,
    required this.color,
    required this.textColor,
  });

  @override
  State<DirectionDetailsScreen> createState() => _DirectionDetailsScreenState();
}

class _DirectionDetailsScreenState extends State<DirectionDetailsScreen> {
  final TransportService _transportService = TransportService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _stops = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final details = await _transportService.getVehicleJourney(widget.vehicleJourneyId);
      setState(() {
        _stops = details['stop_times'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(
          widget.directionName,
          style: TextStyle(color: widget.textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: IconThemeData(color: widget.textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _stops.length,
                  itemBuilder: (context, index) {
                    final stop = _stops[index];
                    final isFirst = index == 0;
                    final isLast = index == _stops.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          const SizedBox(width: 24),
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                color: isFirst ? Colors.transparent : widget.color.withOpacity(0.5),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 4,
                                  color: isLast ? Colors.transparent : widget.color.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stop['stop_name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stop['time'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
