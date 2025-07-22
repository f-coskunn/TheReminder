import 'package:flutter/material.dart';
import '../model/task_model.dart';

class NotificationTypeSelector extends StatefulWidget {
  final List<NotificationType> selectedTypes;
  final Function(List<NotificationType>) onChanged;

  const NotificationTypeSelector({
    Key? key,
    required this.selectedTypes,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NotificationTypeSelector> createState() => _NotificationTypeSelectorState();
}

class _NotificationTypeSelectorState extends State<NotificationTypeSelector> {
  late List<NotificationType> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
    // Always ensure visual is selected
    if (!_selectedTypes.contains(NotificationType.Visual)) {
      _selectedTypes.add(NotificationType.Visual);
    }
  }

  void _toggleNotificationType(NotificationType type) {
    setState(() {
      if (type == NotificationType.Visual) {
        // Visual cannot be unchecked
        return;
      }
      
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
    
    widget.onChanged(_selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Types:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Visual is always enabled. You can also enable vibration and/or audio.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...NotificationType.values.map((type) => _buildNotificationTypeTile(type)),
      ],
    );
  }

  Widget _buildNotificationTypeTile(NotificationType type) {
    final isSelected = _selectedTypes.contains(type);
    final isVisual = type == NotificationType.Visual;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(
              _getNotificationIcon(type),
              color: _getNotificationColor(type),
            ),
            const SizedBox(width: 8),
            Text(type.name),
            if (isVisual) 
              const Text(
                ' (Required)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        subtitle: Text(_getNotificationDescription(type)),
        value: isSelected,
        onChanged: isVisual ? null : (bool? value) {
          _toggleNotificationType(type);
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: _getNotificationColor(type),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.Vibration:
        return Icons.vibration;
      case NotificationType.Visual:
        return Icons.visibility;
      case NotificationType.Audio:
        return Icons.volume_up;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.Vibration:
        return Colors.orange;
      case NotificationType.Visual:
        return Colors.purple;
      case NotificationType.Audio:
        return Colors.blue;
    }
  }

  String _getNotificationDescription(NotificationType type) {
    switch (type) {
      case NotificationType.Vibration:
        return 'Device will vibrate when notification appears';
      case NotificationType.Visual:
        return 'Shows a flashing visual alert on screen';
      case NotificationType.Audio:
        return 'Plays notification sound';
    }
  }
} 