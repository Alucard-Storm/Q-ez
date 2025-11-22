# Firestore Deployment Guide

This guide explains how to deploy Firestore security rules, indexes, and seed data for the Q-ez Quiz Application.

## Prerequisites

1. Firebase project created and configured (see `FIREBASE_SETUP.md`)
2. Firebase CLI installed: `npm install -g firebase-tools`
3. Logged into Firebase: `firebase login`
4. Firebase project initialized: `firebase init firestore`

## Step 1: Deploy Security Rules

Security rules control access to Firestore collections based on user roles and authentication.

```bash
# Deploy security rules
firebase deploy --only firestore:rules
```

The rules file (`firestore.rules`) implements:
- Authentication requirements for all operations
- Role-based access control (student, teacher, admin)
- Ownership validation (users can only modify their own data)
- Read permissions for leaderboards and badges

### Verify Security Rules

After deployment, test the rules:

1. Go to Firebase Console > Firestore Database > Rules
2. Verify the rules are deployed
3. Use the Rules Playground to test access patterns

## Step 2: Deploy Indexes

Indexes optimize query performance for complex queries.

```bash
# Deploy indexes
firebase deploy --only firestore:indexes
```

The indexes file (`firestore.indexes.json`) creates indexes for:
- Student quiz history (by studentId and completedAt)
- Quiz leaderboards (by quizId, score, and completedAt)
- Global leaderboard (by role, level, and averageScore)
- Teacher's quizzes (by teacherId and createdAt)
- Quiz lookup by PIN

### Monitor Index Creation

Indexes may take time to build:

1. Go to Firebase Console > Firestore Database > Indexes
2. Monitor index build status
3. Wait for all indexes to show "Enabled" status

## Step 3: Seed Initial Data

Seed the database with predefined badges and initialize the global leaderboard.

### Option A: Using Flutter App (Recommended for Development)

Run the seed operation from within the app:

```dart
import 'package:q_ez/core/config/firestore_seed_data.dart';

// In your initialization code or admin panel
await FirestoreSeedData.seedAll();
```

### Option B: Using Firebase Console (Manual)

1. Go to Firebase Console > Firestore Database
2. Create the `badges` collection manually
3. Add badge documents with the structure defined in `FIRESTORE_SCHEMA.md`

### Option C: Using Cloud Functions (Recommended for Production)

Create a Cloud Function to seed data:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.seedDatabase = functions.https.onRequest(async (req, res) => {
  // Add authentication check here
  
  const badges = [
    {
      name: 'Quiz Novice',
      description: 'Complete your first quiz',
      iconAsset: 'assets/badges/novice.png',
      type: 'quizzesCompleted',
      requirement: 1,
    },
    // ... add all badges
  ];

  const batch = admin.firestore().batch();
  badges.forEach(badge => {
    const ref = admin.firestore().collection('badges').doc();
    batch.set(ref, { ...badge, id: ref.id });
  });

  await batch.commit();
  res.send('Database seeded successfully');
});
```

Deploy the function:
```bash
firebase deploy --only functions:seedDatabase
```

## Step 4: Verify Deployment

### Check Collections

Verify that collections are accessible:

```bash
# Using Firebase CLI
firebase firestore:get badges --limit 5
```

Or in Firebase Console:
1. Go to Firestore Database
2. Verify `badges` collection exists
3. Verify `leaderboard/global` document exists

### Test Security Rules

Test access patterns:

1. **Student Access**:
   - Can read own profile ✓
   - Can read quizzes ✓
   - Can create quiz attempts ✓
   - Cannot create quizzes ✗

2. **Teacher Access**:
   - Can create quizzes ✓
   - Can update own quizzes ✓
   - Cannot update other teachers' quizzes ✗

3. **Admin Access**:
   - Can access all collections ✓
   - Can modify any document ✓

### Test Queries

Test that indexes work correctly:

```dart
// Test leaderboard query
final leaderboard = await FirebaseFirestore.instance
    .collection('users')
    .where('role', isEqualTo: 'student')
    .orderBy('level', descending: true)
    .orderBy('averageScore', descending: true)
    .limit(10)
    .get();

// Test quiz by PIN
final quiz = await FirebaseFirestore.instance
    .collection('quizzes')
    .where('pin', isEqualTo: '123456')
    .limit(1)
    .get();
```

## Step 5: Production Considerations

### Security

1. **Enable App Check**: Protect against abuse
   ```bash
   firebase deploy --only appcheck
   ```

2. **Set up Backup**: Enable automatic backups
   - Go to Firebase Console > Firestore Database > Backups
   - Configure daily backups

3. **Monitor Usage**: Set up billing alerts
   - Go to Firebase Console > Usage and billing
   - Set budget alerts

### Performance

1. **Monitor Query Performance**:
   - Use Firebase Console > Performance Monitoring
   - Identify slow queries
   - Add indexes as needed

2. **Optimize Security Rules**:
   - Minimize `get()` calls in rules
   - Cache frequently accessed data
   - Use batch operations

3. **Set up Caching**:
   - Enable offline persistence in Flutter:
     ```dart
     FirebaseFirestore.instance.settings = const Settings(
       persistenceEnabled: true,
       cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
     );
     ```

### Monitoring

1. **Enable Firestore Monitoring**:
   - Go to Firebase Console > Firestore Database > Usage
   - Monitor reads, writes, and deletes
   - Set up alerts for unusual activity

2. **Set up Cloud Logging**:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

3. **Create Alerts**:
   - High read/write counts
   - Security rule violations
   - Failed operations

## Rollback Procedure

If deployment causes issues:

### Rollback Security Rules

```bash
# View previous versions
firebase firestore:rules:list

# Rollback to previous version
firebase firestore:rules:release <version>
```

### Rollback Indexes

Indexes cannot be rolled back, but you can:
1. Delete problematic indexes in Firebase Console
2. Redeploy previous `firestore.indexes.json`

## Troubleshooting

### Security Rules Not Working

1. Check rules syntax:
   ```bash
   firebase firestore:rules:validate
   ```

2. Test rules in Firebase Console Rules Playground

3. Check authentication state in app

### Indexes Not Building

1. Check index status in Firebase Console
2. Verify query matches index definition
3. Wait for index build to complete (can take hours for large datasets)

### Permission Denied Errors

1. Verify user is authenticated
2. Check user role in Firestore
3. Review security rules for the operation
4. Check custom claims are set correctly

## Maintenance

### Regular Tasks

1. **Weekly**:
   - Review security rule violations
   - Check query performance
   - Monitor storage usage

2. **Monthly**:
   - Review and optimize indexes
   - Clean up old audit logs
   - Update security rules as needed

3. **Quarterly**:
   - Review and update badge definitions
   - Optimize collection structure
   - Performance audit

## Additional Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Indexes Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
