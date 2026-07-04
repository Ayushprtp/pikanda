import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pikanda/core/utils/aes_helper.dart';
import 'package:pikanda/core/utils/geo.dart';
import 'package:pikanda/shared/models.dart';

void main() {
  group('AES helper', () {
    test('round-trips text with the group key', () {
      final aes = AesHelper.forGroup('group-123', 'saltysalt');
      const plain = '12.9716,77.5946,1699999999999';
      final encrypted = aes.encryptText(plain);
      expect(encrypted, isNot(contains(plain)));
      expect(aes.decryptText(encrypted), plain);
    });

    test('a different group cannot decrypt', () {
      final a = AesHelper.forGroup('group-a', 'salt-a');
      final b = AesHelper.forGroup('group-b', 'salt-b');
      final encrypted = a.encryptText('secret');
      expect(b.decryptText(encrypted), isNot('secret'));
    });

    test('safe code hashing is deterministic and case/space-insensitive', () {
      expect(AesHelper.hashSafeCode('Open Sesame'),
          AesHelper.hashSafeCode('  open sesame '));
    });
  });

  group('geo', () {
    test('haversine distance is ~0 for the same point', () {
      expect(haversineKm(12.9, 77.5, 12.9, 77.5), closeTo(0, 0.001));
    });

    test('formatDistance switches units', () {
      expect(formatDistance(0.4), '400 m');
      expect(formatDistance(2.34), '2.3 km');
    });
  });

  group('models', () {
    test('Mood.fromKey falls back to neutral', () {
      expect(Mood.fromKey('happy'), Mood.happy);
      expect(Mood.fromKey('nonsense'), Mood.neutral);
    });

    test('custom mood labels override defaults', () {
      expect(Mood.happy.label({'happy': 'Pikachu Energy'}), 'Pikachu Energy');
      expect(Mood.happy.label(null), 'Happy');
    });

    test('Pet growth stage helpers', () {
      final egg = Pet.fromJson({
        'id': '1', 'group_id': 'g', 'name': 'Bao', 'species': 'panda',
        'stage': 'egg', 'hunger': 80, 'happiness': 80, 'energy': 80,
        'cleanliness': 80, 'xp': 0, 'level': 0,
      });
      expect(egg.displayEmoji, '🥚');
      final adult = Pet.fromJson({
        'id': '1', 'group_id': 'g', 'name': 'Bao', 'species': 'panda',
        'stage': 'adult', 'hunger': 90, 'happiness': 90, 'energy': 90,
        'cleanliness': 90, 'xp': 400, 'level': 12,
      });
      expect(adult.displayEmoji, '🐼');
    });

    test('GroupThemeConfig parses hex colours', () {
      final cfg = GroupThemeConfig.fromJson({
        'primary_color': '#FF0000',
        'accent_color': '#00FF00',
        'font_style': 'playful',
      });
      expect(cfg.primary, const Color(0xFFFF0000));
      expect(cfg.fontFamily, 'Pandastudio');
    });
  });
}
