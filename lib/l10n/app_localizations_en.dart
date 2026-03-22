// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VerveForge';

  @override
  String get tabFeed => 'Feed';

  @override
  String get tabGyms => 'Gyms';

  @override
  String get tabChallenge => 'Challenge';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabNearby => 'Nearby';

  @override
  String get loginTitle => 'Login to VerveForge';

  @override
  String get loginSubtitle => 'Record · Discover · Challenge';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get switchToRegister => 'No account? Register now';

  @override
  String get switchToLogin => 'Have an account? Login';

  @override
  String get orLoginWith => 'Or login with';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get privacyAgreement => 'By logging in, you agree to our';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get onboardingStep1Title => 'Choose Your Sports';

  @override
  String get onboardingStep1Subtitle =>
      'Select the sports you\'re interested in (multiple)';

  @override
  String get onboardingStep2Title => 'Choose Your City';

  @override
  String get onboardingStep2Subtitle =>
      'We\'ll recommend nearby gyms and buddies';

  @override
  String get onboardingStep3Title => 'Complete Your Profile';

  @override
  String get onboardingStep3Subtitle => 'Set your avatar and nickname';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get sportHyrox => 'HYROX';

  @override
  String get sportCrossfit => 'CrossFit';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportPilates => 'Pilates';

  @override
  String get sportRunning => 'Running';

  @override
  String get sportSwimming => 'Swimming';

  @override
  String get sportStrength => 'Strength';

  @override
  String get sportOther => 'Other';

  @override
  String get cityBeijing => 'Beijing';

  @override
  String get cityShanghai => 'Shanghai';

  @override
  String get cityGuangzhou => 'Guangzhou';

  @override
  String get cityShenzhen => 'Shenzhen';

  @override
  String get cityHongkong => 'Hong Kong';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelElite => 'Elite';

  @override
  String get feedTitle => 'Feed';

  @override
  String get feedTabFollowing => 'Following';

  @override
  String get feedTabNearby => 'Nearby';

  @override
  String get feedTabLatest => 'Latest';

  @override
  String get feedTabRecommend => 'For You';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverNearbyPeople => 'Nearby People';

  @override
  String get discoverNearbyGyms => 'Nearby Gyms';

  @override
  String get sendBuddyRequest => 'Buddy Up';

  @override
  String get nearbyTitle => 'Nearby';

  @override
  String get nearbyBuddies => 'Nearby Buddies';

  @override
  String get nearbyGymsRecommend => 'Recommended Gyms';

  @override
  String get nearbyNoBuddies => 'No buddies nearby';

  @override
  String get nearbyNoBuddiesTip => 'Try expanding your search range';

  @override
  String get nearbyNoGyms => 'No gyms nearby';

  @override
  String get nearbyNoGymsTip => 'Submit a gym you frequent';

  @override
  String get workoutCreate => 'Log Workout';

  @override
  String get workoutType => 'Sport Type';

  @override
  String get workoutDuration => 'Duration (min)';

  @override
  String get workoutIntensity => 'Intensity';

  @override
  String get workoutNotes => 'Notes';

  @override
  String get workoutPhotos => 'Photos';

  @override
  String get workoutSave => 'Save';

  @override
  String get workoutShareAsPost => 'Also share as a post?';

  @override
  String get workoutCalendar => 'Calendar';

  @override
  String get workoutDetail => 'Workout Detail';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get workoutDraft => 'Draft';

  @override
  String get workoutDrafts => 'Workout Drafts';

  @override
  String get workoutDate => 'Date';

  @override
  String get workoutTime => 'Time';

  @override
  String get workoutSaveDraft => 'Save Draft';

  @override
  String get workoutDeleteConfirm =>
      'Are you sure you want to delete this workout?';

  @override
  String workoutMinutes(int count) {
    return '$count min';
  }

  @override
  String workoutIntensityLevel(int level) {
    return 'Intensity $level/10';
  }

  @override
  String get workoutThisWeek => 'This Week';

  @override
  String get workoutThisMonth => 'This Month';

  @override
  String get workoutTotalHours => 'Total Hours';

  @override
  String get workoutFilterAll => 'All';

  @override
  String get workoutNoRecords => 'No workout records yet';

  @override
  String get workoutStartFirst => 'Log your first workout';

  @override
  String get healthSync => 'Apple Health Sync';

  @override
  String get healthSyncDescription =>
      'Automatically sync workout data from Apple Health';

  @override
  String get healthSyncNow => 'Sync Now';

  @override
  String get healthSyncing => 'Syncing...';

  @override
  String get healthSyncSuccess => 'Sync complete';

  @override
  String get healthSyncError => 'Sync failed';

  @override
  String get healthPermissionDenied =>
      'Please allow VerveForge to access health data in Settings';

  @override
  String get metricsTitle => 'Sport-Specific Metrics (Optional)';

  @override
  String get metricsStation => 'Station';

  @override
  String get metricsTime => 'Time';

  @override
  String get metricsTotalTime => 'Total Time';

  @override
  String get metricsWod => 'WOD Name';

  @override
  String get metricsScore => 'Score';

  @override
  String get metricsWodType => 'WOD Type';

  @override
  String get metricsMovement => 'Movements';

  @override
  String get metricsDistance => 'Distance (km)';

  @override
  String get metricsPace => 'Pace (min/km)';

  @override
  String get metricsElevation => 'Elevation (m)';

  @override
  String get metricsFocusArea => 'Focus Areas';

  @override
  String get metricsDifficulty => 'Difficulty';

  @override
  String get metricsClassName => 'Class Name';

  @override
  String get dataCollectionConsent => 'Training Data Collection Authorization';

  @override
  String get dataCollectionDesc =>
      'To provide workout analytics, VerveForge needs to collect:\n\n• Sport performance data (times, scores, metrics)\n• Apple Health data (heart rate, calories, steps)\n• Training photos and videos\n\nYour data is encrypted and stored securely. You can export or delete it anytime in Settings.';

  @override
  String get challengeTitle => 'Challenges';

  @override
  String get challengeCreate => 'Create Challenge';

  @override
  String get challengeJoin => 'Join';

  @override
  String get challengeLeave => 'Leave';

  @override
  String get challengeLeaderboard => 'Leaderboard';

  @override
  String get challengeCheckIn => 'Check In';

  @override
  String get challengeProgress => 'Progress';

  @override
  String get challengeDetail => 'Challenge Detail';

  @override
  String get challengeStartDate => 'Start Date';

  @override
  String get challengeEndDate => 'End Date';

  @override
  String get challengeGoalType => 'Goal Type';

  @override
  String get challengeGoalValue => 'Goal Value';

  @override
  String get challengeGoalSessions => 'Total Sessions';

  @override
  String get challengeGoalMinutes => 'Total Minutes';

  @override
  String get challengeGoalDays => 'Total Days';

  @override
  String get challengeCity => 'City';

  @override
  String get challengeCityAll => 'All Cities';

  @override
  String get challengeSportType => 'Sport Type';

  @override
  String get challengeMaxParticipants => 'Max Participants';

  @override
  String get challengeDescription => 'Description';

  @override
  String challengeParticipants(int count) {
    return '$count participants';
  }

  @override
  String challengeRemainingDays(int days) {
    return '$days days left';
  }

  @override
  String get challengeStatusActive => 'In Progress';

  @override
  String get challengeStatusCompleted => 'Completed';

  @override
  String get challengeStatusCancelled => 'Cancelled';

  @override
  String get challengeFull => 'Full';

  @override
  String get challengeNoRecords => 'No challenges yet';

  @override
  String get challengeStartFirst =>
      'Create or join a challenge to compete with others';

  @override
  String get challengeCreateSuccess => 'Challenge created';

  @override
  String get challengeJoinSuccess => 'Joined challenge';

  @override
  String get challengeLeaveSuccess => 'Left challenge';

  @override
  String get challengeLeaveConfirm =>
      'Are you sure you want to leave this challenge?';

  @override
  String get challengeRank => 'Rank';

  @override
  String get challengeCheckInCount => 'Check-ins';

  @override
  String get challengeRealtime => 'Live';

  @override
  String get challengeNewAvailable => 'Challenges updated, tap to refresh';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileWorkoutLog => 'Workout Log';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileNickname => 'Nickname';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileAvatar => 'Avatar';

  @override
  String get profileBioHint => 'Tell us about yourself';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileGenderOther => 'Other';

  @override
  String get profileGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get profileCity => 'City';

  @override
  String get profileExperienceLevel => 'Experience Level';

  @override
  String get profileSportPreference => 'Sport Preferences';

  @override
  String get profileNicknameError =>
      'Please enter a valid nickname (2-20 characters)';

  @override
  String get profileSportSelectionError => 'Please select at least one sport';

  @override
  String get profileSaveSuccess => 'Saved successfully';

  @override
  String get profileUserNotFound => 'User not found';

  @override
  String get avatarPickerGallery => 'Choose from gallery';

  @override
  String get avatarPickerCamera => 'Take a photo';

  @override
  String get avatarPickerCropTitle => 'Crop avatar';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLogout => 'Log Out';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsExportData => 'Export My Data';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyAgree => 'I have read and agree';

  @override
  String get privacyDisagree => 'Disagree';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get commonReport => 'Report';

  @override
  String get commonBlock => 'Block';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonEmpty => 'No data';

  @override
  String get commonError => 'Something went wrong, please retry';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonNoNetwork => 'No network connection';

  @override
  String get commonDone => 'Done';

  @override
  String get chatTitle => 'Messages';

  @override
  String get chatNoConversations => 'No messages yet';

  @override
  String get chatNoConversationsTip => 'Start chatting with your buddies';

  @override
  String get chatEmpty => 'Send the first message';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get gymTitle => 'Gyms';

  @override
  String get gymNearby => 'Nearby Gyms';

  @override
  String get gymSearch => 'Search gyms...';

  @override
  String get gymDetail => 'Gym Detail';

  @override
  String get gymSubmit => 'Submit Gym';

  @override
  String get gymAddress => 'Address';

  @override
  String get gymPhone => 'Phone';

  @override
  String get gymWebsite => 'Website';

  @override
  String get gymOpeningHours => 'Opening Hours';

  @override
  String get gymSportTypes => 'Sport Types';

  @override
  String get gymReviews => 'Reviews';

  @override
  String get gymWriteReview => 'Write Review';

  @override
  String get gymRating => 'Rating';

  @override
  String get gymNoReviews => 'No reviews yet';

  @override
  String get gymSubmitSuccess => 'Gym submitted, pending review';

  @override
  String get gymPending => 'Pending';

  @override
  String get gymVerified => 'Verified';

  @override
  String get gymFavorite => 'Favorite';

  @override
  String get gymFavorited => 'Favorited';

  @override
  String get gymFavoriteAdded => 'Added to favorites';

  @override
  String get gymFavoriteRemoved => 'Removed from favorites';

  @override
  String get gymMyFavorites => 'My Favorite Gyms';

  @override
  String get gymNoFavorites => 'No favorites yet';

  @override
  String get gymClaimThis => 'Claim This Gym';

  @override
  String get gymClaimConfirm => 'Claim Gym';

  @override
  String get gymClaimConfirmDesc =>
      'Are you the owner or manager of this gym? Submitting a claim will require review.';

  @override
  String get gymClaimSubmit => 'Submit Claim';

  @override
  String get gymClaimSuccess => 'Claim submitted, pending review';

  @override
  String get gymClaimStatus => 'Claim status';

  @override
  String get gymClaimPending => 'Under Review';

  @override
  String get gymClaimApproved => 'Approved';

  @override
  String get gymClaimRejected => 'Rejected';

  @override
  String get postCreate => 'New Post';

  @override
  String get postPublish => 'Publish';

  @override
  String get postPublishSuccess => 'Post published';

  @override
  String get postContentHint => 'Share your workout or thoughts...';

  @override
  String get postCity => 'City';

  @override
  String get postCreateSubtitle => 'Share your workout moments';

  @override
  String get postEmpty => 'No posts yet';

  @override
  String get postEmptyTip => 'Be the first to share a post';

  @override
  String get postNewAvailable => 'New posts available, tap to refresh';

  @override
  String get postNoFollowing => 'No following posts';

  @override
  String get postFollowTip => 'Follow athletes to see their updates';

  @override
  String postLikes(int count) {
    return '$count likes';
  }

  @override
  String postComments(int count) {
    return '$count comments';
  }

  @override
  String get postDeleteConfirm => 'Are you sure you want to delete this post?';

  @override
  String get postDeleted => 'Post deleted';

  @override
  String get appLaunchConsentTitle => 'Welcome to VerveForge';

  @override
  String get appLaunchConsentDesc =>
      'Before using our services, please review how we handle your data:';

  @override
  String get appLaunchConsentItem1 =>
      'Account info: email, Apple ID, nickname, avatar';

  @override
  String get appLaunchConsentItem2 =>
      'Training data: workout logs, Apple Health sync, photos';

  @override
  String get appLaunchConsentItem3 =>
      'Location: for discovering nearby gyms and workout buddies';

  @override
  String get appLaunchConsentItem4 =>
      'Your data is encrypted and you can export or delete it anytime';

  @override
  String get appLaunchConsentReadFull => 'Read full Privacy Policy';

  @override
  String get profileNoBio => 'No bio yet';

  @override
  String get profileRegisterFirst => 'Please complete registration first';

  @override
  String get profileGoRegister => 'Register';

  @override
  String get profileMyChallenges => 'My Challenges';

  @override
  String get profileMyBuddies => 'My Buddies';

  @override
  String get profileSectionTraining => 'TRAINING';

  @override
  String get profileSectionSocial => 'SOCIAL';

  @override
  String get profileSectionAccount => 'ACCOUNT';

  @override
  String get buddyListTitle => 'Buddies';

  @override
  String get buddyRequests => 'Buddy Requests';

  @override
  String get buddyReceived => 'Received';

  @override
  String get buddySent => 'Sent';

  @override
  String get buddyAccept => 'Accept';

  @override
  String get buddyReject => 'Decline';

  @override
  String get buddyCancel => 'Cancel';

  @override
  String get buddyRemove => 'Remove';

  @override
  String get buddyPending => 'Pending';

  @override
  String get buddyAccepted => 'You are now buddies';

  @override
  String get buddyNoRequests => 'No buddy requests';

  @override
  String get buddyNoRequestsTip =>
      'Discover workout buddies on the Nearby page';

  @override
  String get buddyNoSentRequests => 'No sent requests';

  @override
  String get buddyNoBuddies => 'No buddies yet';

  @override
  String get buddyNoBuddiesTip => 'Discover workout buddies on the Nearby page';

  @override
  String get buddyRemoveConfirm => 'Remove buddy';

  @override
  String get buddyRemoveConfirmDesc =>
      'Are you sure? You will need to send a new request to reconnect.';

  @override
  String get buddyRemoved => 'Buddy removed';

  @override
  String get profileMyDrafts => 'Workout Drafts';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get settingsFollowSystem => 'Follow System';

  @override
  String get settingsOpenSource => 'Open Source';

  @override
  String get settingsLogoutConfirm => 'Confirm logout?';

  @override
  String get settingsLogoutDesc => 'You will need to log in again';

  @override
  String get aiAvatarTitle => 'My AI Avatar';

  @override
  String get aiAvatarCreate => 'Create AI Avatar';

  @override
  String get aiAvatarEdit => 'Edit Avatar';

  @override
  String get aiAvatarDelete => 'Delete Avatar';

  @override
  String get aiAvatarDeleteConfirm =>
      'Delete your AI avatar? This cannot be undone.';

  @override
  String get aiAvatarDeleted => 'AI avatar deleted';

  @override
  String get aiAvatarSaved => 'AI avatar saved';

  @override
  String get aiAvatarCreatedTitle => 'Your AI Twin is Ready!';

  @override
  String get aiAvatarCreatedSubtitle =>
      'Start a conversation and let it get to know you';

  @override
  String get aiAvatarEmpty => 'No AI avatar yet';

  @override
  String get aiAvatarEmptyTip => 'Create an AI avatar that represents you';

  @override
  String get aiAvatarStepName => 'Name & Style';

  @override
  String get aiAvatarStepPersonality => 'Personality';

  @override
  String get aiAvatarStepStyle => 'Appearance';

  @override
  String get aiAvatarName => 'Avatar Name';

  @override
  String get aiAvatarNameHint => 'Give your avatar a name';

  @override
  String get aiAvatarPhoto => 'Avatar Photo';

  @override
  String get aiAvatarCustomPrompt => 'Custom Instructions';

  @override
  String get aiAvatarCustomPromptHint =>
      'Optional: Add special instructions for your avatar';

  @override
  String get aiAvatarPickPreset => 'Choose a preset avatar';

  @override
  String get aiAvatarOrUpload => 'or upload your own';

  @override
  String get aiAvatarPreviewTitle => 'Style Preview';

  @override
  String get aiAvatarPreviewHint => 'This is how your avatar will reply:';

  @override
  String get aiAvatarSelectTraitsHint =>
      'Select traits that match your vibe (up to 5)';

  @override
  String get presetRunner => 'Runner';

  @override
  String get presetYogi => 'Yogi';

  @override
  String get presetLifter => 'Lifter';

  @override
  String get presetSwimmer => 'Swimmer';

  @override
  String get presetCyclist => 'Cyclist';

  @override
  String get presetBoxer => 'Boxer';

  @override
  String get presetClimber => 'Climber';

  @override
  String get presetDancer => 'Dancer';

  @override
  String get presetMartial => 'Martial Artist';

  @override
  String get presetSkier => 'Skier';

  @override
  String get presetSurfer => 'Surfer';

  @override
  String get presetTennis => 'Tennis';

  @override
  String get presetBasketball => 'Basketball';

  @override
  String get presetSoccer => 'Soccer';

  @override
  String get presetHiker => 'Hiker';

  @override
  String get presetGymnast => 'Gymnast';

  @override
  String get presetRower => 'Rower';

  @override
  String get presetSkater => 'Skater';

  @override
  String get presetNinja => 'Ninja';

  @override
  String get presetRobot => 'Robot';

  @override
  String get presetFire => 'Fire';

  @override
  String get presetLightning => 'Lightning';

  @override
  String get presetStar => 'Star';

  @override
  String get presetDiamond => 'Diamond';

  @override
  String get aiTraitEarlyRunner => 'Early Runner';

  @override
  String get aiTraitYogaMaster => 'Yoga Master';

  @override
  String get aiTraitIronAddict => 'Iron Addict';

  @override
  String get aiTraitCrossfitFanatic => 'CrossFit Fan';

  @override
  String get aiTraitMarathoner => 'Marathoner';

  @override
  String get aiTraitGymRat => 'Gym Rat';

  @override
  String get aiTraitOutdoorExplorer => 'Outdoor Explorer';

  @override
  String get aiTraitFlexibilityPro => 'Flexibility Pro';

  @override
  String get aiTraitTeamPlayer => 'Team Player';

  @override
  String get aiTraitSoloWarrior => 'Solo Warrior';

  @override
  String get aiTraitTechGeek => 'Tech Geek';

  @override
  String get aiTraitNutritionNerd => 'Nutrition Nerd';

  @override
  String get aiTraitRestDayHater => 'No Rest Days';

  @override
  String get aiTraitWarmupSkipper => 'Warmup Skipper';

  @override
  String get aiTraitPrBeast => 'PR Beast';

  @override
  String get aiTraitCheerleader => 'Cheerleader';

  @override
  String get aiTraitEnthusiastic => 'Enthusiastic';

  @override
  String get aiTraitProfessional => 'Professional';

  @override
  String get aiTraitHumorous => 'Humorous';

  @override
  String get aiTraitEncouraging => 'Encouraging';

  @override
  String get aiTraitCalm => 'Calm';

  @override
  String get aiTraitFriendly => 'Friendly';

  @override
  String get aiTraitDirect => 'Direct';

  @override
  String get aiTraitCurious => 'Curious';

  @override
  String get aiStyleLively => 'Lively';

  @override
  String get aiStyleLivelyDesc =>
      'Energetic and upbeat, uses exclamation marks freely';

  @override
  String get aiStyleLivelyPreview =>
      'Awesome!! Just crushed a 5K this morning 🏃💨 The weather was perfect! Wanna join me next time?';

  @override
  String get aiStyleSteady => 'Steady';

  @override
  String get aiStyleSteadyDesc =>
      'Calm and thoughtful, keeps it short and factual';

  @override
  String get aiStyleSteadyPreview =>
      'Morning run done. 5K in 24 min. Pace was consistent. Weather helped.';

  @override
  String get aiStyleHumorous => 'Humorous';

  @override
  String get aiStyleHumorousDesc => 'Witty and playful, loves a good pun';

  @override
  String get aiStyleHumorousPreview =>
      'Ran 5K today... well, my legs ran. My brain was still in bed 😂 At least my playlist kept me going!';

  @override
  String get aiStyleFriendly => 'Friendly & Casual';

  @override
  String get aiStyleProfessional => 'Professional & Concise';

  @override
  String get aiStyleEncouraging => 'Warm & Encouraging';

  @override
  String get aiAutoReply => 'Auto Reply';

  @override
  String get aiAutoReplyDesc =>
      'When you\'re offline for 5+ minutes, your avatar replies automatically';

  @override
  String get aiAutoReplyEnabled => 'Auto reply enabled';

  @override
  String get aiAutoReplyDisabled => 'Auto reply disabled';

  @override
  String get aiGeneratedLabel => 'Replied by AI Avatar';

  @override
  String get aiAvatarChat => 'Chat with Avatar';

  @override
  String get aiAvatarChatHint => 'Say something to your avatar...';

  @override
  String get aiAvatarChatIntro =>
      'Chat with your AI avatar to see how it responds';

  @override
  String get aiAvatarThinking => 'Avatar is thinking...';

  @override
  String get aiConsentTitle => 'AI Data Authorization';

  @override
  String get aiConsentDesc =>
      'To create an AI avatar, we need to process the following data:';

  @override
  String get aiConsentItem1 =>
      'Your profile info (nickname, bio, sports, city)';

  @override
  String get aiConsentItem2 => 'Recent chat messages (last 10) for context';

  @override
  String get aiConsentItem3 => 'Your recent public posts (last 5)';

  @override
  String get aiConsentItem4 =>
      'Data is processed via AI and not permanently stored';

  @override
  String get aiConsentItem5 =>
      'Others will see an \"AI replied\" label on auto-replies';

  @override
  String get aiConsentAgree => 'Agree & Continue';

  @override
  String get aiConsentDisagree => 'Cancel';

  @override
  String get aiChatQuickLegDay => 'Leg day today';

  @override
  String get aiChatQuickRan5k => 'Just ran 5km';

  @override
  String get aiChatQuickFeelSore => 'Feeling sore';

  @override
  String get aiChatQuickRestDay => 'Rest day today';

  @override
  String get aiChatQuickNewPR => 'New PR!';

  @override
  String get aiChatStartChat => 'Start Chat';

  @override
  String get aiChatNoMessages => 'No messages yet';

  @override
  String get aiChatNoMessagesTip => 'Send a message to start chatting';

  @override
  String get aiChatSendFailed => 'Failed to send, please retry';

  @override
  String get aiChatLoadingHistory => 'Loading history...';

  @override
  String aiChatMessageTime(String time) {
    return '$time';
  }

  @override
  String get aiChatDisclaimer =>
      'AI replies are for reference only and do not represent the user';

  @override
  String get aiChatThinkingWorkout =>
      'Avatar is thinking about your workout today…';

  @override
  String get aiChatThinkingReply => 'Avatar is composing a reply…';

  @override
  String get aiChatThinkingAnalyze => 'Avatar is analyzing your state…';

  @override
  String get aiChatEmptyLearning => 'Avatar is learning your habits…';

  @override
  String get aiChatSmartRecommend => 'Smart Suggest';

  @override
  String get aiAutoReplyActive => 'AI avatar is replying on your behalf';

  @override
  String get aiAutoReplyBadge => 'AI auto-reply';

  @override
  String get aiAutoReplyConsentRequired =>
      'Please complete AI data authorization first';

  @override
  String get aiAutoReplyStatusOn =>
      'Auto-reply is on. Avatar will reply when you\'re offline';

  @override
  String get aiAutoReplyStatusOff => 'Auto-reply is off';

  @override
  String get aiProfileUpdate => 'Profile Learning';

  @override
  String get aiProfileUpdateBtn => 'Update Profile';

  @override
  String get aiProfileUpdating => 'Avatar is learning your habits...';

  @override
  String get aiProfileUpdateSuccess => 'Profile updated';

  @override
  String get aiProfileLastUpdated => 'Last updated';

  @override
  String get aiProfileNeverUpdated => 'Profile not yet updated';

  @override
  String get aiProfileAutoRefresh => 'Auto-learn after chat';

  @override
  String get aiProfileManualUpdateBtn => 'Update My Profile';

  @override
  String get aiProfileUpdateConfirmTitle => 'Update AI Avatar Profile?';

  @override
  String get aiProfileUpdateConfirmDesc =>
      'Your avatar\'s personality, habits, and speaking style will be updated based on recent conversations and workout records. Data is only used for replies, not for other purposes. Confirm update?';

  @override
  String get aiProfileUpdateConfirmBtn => 'Confirm Update';

  @override
  String get aiProfileUpdateFailed => 'Profile update failed, please retry';

  @override
  String get aiProfileUpdateHint =>
      'Recorded! You can update your avatar\'s profile in the detail page';

  @override
  String get aiChatCopied => 'Copied';

  @override
  String get aiChatCopyMessage => 'Copy message';

  @override
  String get aiChatVoiceComingSoon => 'Voice input coming soon';

  @override
  String get aiChatClear => 'Clear conversation';

  @override
  String get aiChatQuickPhrases => 'Quick phrases';

  @override
  String get aiChatVoice => 'Voice input';

  @override
  String get aiReplyFilteredHint => 'Reply filtered (content inappropriate)';

  @override
  String get aiReplyFilteredSystem =>
      'This reply was filtered by content review';

  @override
  String get aiReplyFilteredNotice =>
      'Avatar\'s reply was blocked for safety reasons';

  @override
  String get aiReplyFilteredFallback =>
      'Avatar is temporarily unable to reply. Please try again later.';

  @override
  String get aiContentSafetyTitle => 'Content Safety';

  @override
  String get aiShareTitle => 'Share Avatar';

  @override
  String get aiShareBtn => 'Share My Avatar';

  @override
  String get aiShareSignUpToChat => 'Sign up to chat';

  @override
  String get aiShareSubtitle => 'Share your AI avatar with friends';

  @override
  String get aiShareToFeed => 'Share to Feed';

  @override
  String get aiShareToFeedDesc => 'Post your avatar in the activity feed';

  @override
  String get aiShareToChallenge => 'Share to Challenge';

  @override
  String get aiShareToChallengeDesc => 'Show your avatar in a challenge';

  @override
  String get aiShareToGroup => 'Share to Group Chat';

  @override
  String get aiShareToGroupDesc => 'Send your avatar to a group conversation';

  @override
  String get aiShareCopyLink => 'Copy Share Link';

  @override
  String get aiShareConfirmTitle => 'Share Your Avatar?';

  @override
  String get aiShareConfirmDesc =>
      'Your avatar\'s public info (name, avatar, personality, style) will be visible to others. Private data will not be shared.';

  @override
  String get aiShareConfirmBtn => 'Confirm Share';

  @override
  String get aiShareSuccess => 'Avatar shared successfully';

  @override
  String get aiShareFailed => 'Share failed, please retry';

  @override
  String get aiShareLimitReached => 'Daily share limit reached (max 5/day)';

  @override
  String get aiShareLinkCopied => 'Share link copied';

  @override
  String get aiShareViewTitle => 'AI Avatar';

  @override
  String get aiShareNotFound => 'Avatar not found';

  @override
  String get aiShareNotFoundDesc =>
      'This share link may have expired or the avatar was deleted';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationMarkAllRead => 'Read All';

  @override
  String get notificationEmpty => 'No notifications';

  @override
  String get notificationEmptyTip =>
      'You\'ll see updates here when someone interacts with you';
}
