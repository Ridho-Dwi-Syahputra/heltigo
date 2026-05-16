# Implementation Plan

## Phase 1: Foundation - Create Responsive Utilities

- [x] 1. Create ResponsiveUtils class
  - Create new file `lib/utils/responsive_utils.dart`
  - Add breakpoint constants (smallScreenWidth: 375, mediumScreenWidth: 414, largeScreenWidth: 768)
  - Add breakpoint constants for height (smallScreenHeight: 667, mediumScreenHeight: 812, largeScreenHeight: 896)
  - Implement `isSmallScreen(BuildContext)` method
  - Implement `isMediumScreen(BuildContext)` method
  - Implement `isLargeScreen(BuildContext)` method
  - Implement `responsiveWidth(BuildContext, {small, medium, large})` method
  - Implement `responsiveHeight(BuildContext, {small, medium, large})` method
  - Implement `responsiveFontSize(BuildContext, baseSize)` method with scaling factors (0.9x for small, 1.0x for medium, 1.05x for large, 1.1x for extra large)
  - Implement `responsivePadding(BuildContext, {small, medium, large})` method
  - Add comprehensive documentation comments for all methods
  - _Requirements: 2.19_

- [~] 2. Write unit tests for ResponsiveUtils
  - Create test file `test/utils/responsive_utils_test.dart`
  - Test `isSmallScreen()` returns true for width < 375
  - Test `isMediumScreen()` returns true for width 375-768
  - Test `isLargeScreen()` returns true for width >= 768
  - Test `responsiveFontSize()` scales correctly (0.9x, 1.0x, 1.05x, 1.1x)
  - Test `responsivePadding()` returns correct EdgeInsets for each breakpoint
  - Test `responsiveWidth()` returns correct values for small/medium/large
  - Test `responsiveHeight()` returns correct values for small/medium/large
  - Mock MediaQuery data for different screen sizes
  - Verify all tests pass with `flutter test test/utils/responsive_utils_test.dart`
  - _Requirements: 2.19_

## Phase 2: Bug Condition Exploration Tests (BEFORE FIX)

- [~] 3. Write bug condition exploration test for Timeline Slider
  - **Property 1: Bug Condition** - Timeline Slider Should Not Exist
  - **CRITICAL**: Write this test BEFORE removing the timeline slider
  - **GOAL**: Confirm the timeline slider exists in unfixed code (test will FAIL)
  - **DO NOT attempt to fix the code when this test fails**
  - Create test file `test/screens/setup/setup_goal_screen_test.dart`
  - Test that SetupGoalScreen renders successfully
  - Test that timeline slider widget (Slider widget with key containing 'timeline') exists in widget tree
  - Test that calorie info card exists in widget tree
  - Run test on UNFIXED code with `flutter test test/screens/setup/setup_goal_screen_test.dart`
  - **EXPECTED OUTCOME**: Test FAILS because timeline slider exists (this confirms the bug)
  - Document finding: "Timeline slider found in SetupGoalScreen at step 4/7"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.1_

- [~] 4. Write bug condition exploration test for Statistics Card Overflow
  - **Property 1: Bug Condition** - Statistics Card Overflow on Small Screens
  - **CRITICAL**: Write this test BEFORE fixing overflow errors
  - **GOAL**: Surface overflow errors in unfixed code (test will FAIL)
  - **DO NOT attempt to fix the test or code when it fails**
  - **Scoped PBT Approach**: Test specific screen size (320x568) where overflow is known to occur
  - Create test file `test/screens/workout/workout_session_detail_screen_test.dart`
  - Test that WorkoutSessionDetailScreen renders on small screen (320x568)
  - Test that statistics card renders without overflow errors (expect(tester.takeException(), isNull))
  - Test that all statistics text is visible (28 mnt, 16 set, 156 reps, 245 kkal)
  - Run test on UNFIXED code with `flutter test test/screens/workout/workout_session_detail_screen_test.dart`
  - **EXPECTED OUTCOME**: Test FAILS with "BOTTOM OVERFLOWED BY X PIXELS" error
  - Document counterexample: "Statistics card overflows by X pixels on 320x568 screen"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.2, 2.3, 2.4, 2.5_

- [~] 5. Write bug condition exploration test for Bottom Navigation Spacing
  - **Property 1: Bug Condition** - Uneven Bottom Navigation Spacing
  - **CRITICAL**: Write this test BEFORE fixing navigation spacing
  - **GOAL**: Confirm uneven spacing exists in unfixed code (test will FAIL)
  - **DO NOT attempt to fix the code when this test fails**
  - Create test file `test/screens/main/main_scaffold_test.dart`
  - Test that MainScaffold renders with BottomNavigationBar
  - Test that BottomNavigationBar has 4 items (Home, Latihan, Makan, Progress)
  - Test that BottomNavigationBar has type: BottomNavigationBarType.fixed
  - Test that all navigation items have consistent spacing (measure icon positions)
  - Run test on UNFIXED code with `flutter test test/screens/main/main_scaffold_test.dart`
  - **EXPECTED OUTCOME**: Test FAILS because type is not set or spacing is uneven
  - Document finding: "BottomNavigationBar missing type: fixed, causing uneven spacing"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.6, 2.7_

- [~] 6. Write bug condition exploration test for Onboarding Text Visibility
  - **Property 1: Bug Condition** - Onboarding Text Cut Off on Small Screens
  - **CRITICAL**: Write this test BEFORE fixing onboarding responsiveness
  - **GOAL**: Confirm text is cut off on small screens in unfixed code (test will FAIL)
  - **DO NOT attempt to fix the code when this test fails**
  - **Scoped PBT Approach**: Test specific small screen size (320x568) where text cutoff occurs
  - Create test file `test/screens/splash/onboarding_screen_test.dart`
  - Test that OnboardingScreen renders on small screen (320x568)
  - Test that title text "Latihan Terbaik\nUntuk Kamu" is fully visible (not clipped)
  - Test that description text is fully visible or scrollable
  - Test that image height is appropriate for screen size
  - Run test on UNFIXED code with `flutter test test/screens/splash/onboarding_screen_test.dart`
  - **EXPECTED OUTCOME**: Test FAILS because text is clipped or overflows
  - Document counterexample: "Onboarding title clipped on 320x568 screen, description not fully visible"
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.8, 2.9, 2.10, 2.11_

- [~] 7. Write bug condition exploration test for General Responsiveness
  - **Property 1: Bug Condition** - Multiple Screens Show Overflow on Small Devices
  - **CRITICAL**: Write this test BEFORE applying responsive fixes
  - **GOAL**: Identify all screens with responsiveness issues (test will FAIL)
  - **DO NOT attempt to fix the code when this test fails**
  - **Scoped PBT Approach**: Test multiple key screens on 320px width device
  - Create test file `test/responsiveness/general_responsiveness_test.dart`
  - Test HomeScreen renders without overflow on 320x568
  - Test WorkoutListScreen renders without overflow on 320x568
  - Test MealListScreen renders without overflow on 320x568
  - Test ProgressScreen renders without overflow on 320x568
  - Test ProfileScreen renders without overflow on 320x568
  - For each screen, assert no overflow errors (expect(tester.takeException(), isNull))
  - Run test on UNFIXED code with `flutter test test/responsiveness/general_responsiveness_test.dart`
  - **EXPECTED OUTCOME**: Test FAILS with overflow errors on multiple screens
  - Document all screens with overflow issues and specific error messages
  - Mark task complete when test is written, run, and failures are documented
  - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18_

## Phase 3: Preservation Property Tests (BEFORE FIX)

- [~] 8. Write preservation tests for Setup Wizard Flow
  - **Property 2: Preservation** - Setup Wizard Navigation and Data Collection
  - **IMPORTANT**: Follow observation-first methodology - run on UNFIXED code first
  - Observe: Setup wizard has 7 steps, navigation works, data is collected
  - Create test file `test/screens/setup/setup_wizard_flow_test.dart`
  - Test that setup wizard starts at step 1
  - Test that "Next" button navigates to next step
  - Test that all 7 steps are accessible
  - Test that goal selection works (Turunkan Berat, Jaga Berat, Naikkan Massa Otot)
  - Test that target weight input appears conditionally based on goal
  - Test that data is stored correctly in state
  - Test that "Continue" button enables/disables based on input validation
  - Run test on UNFIXED code with `flutter test test/screens/setup/setup_wizard_flow_test.dart`
  - **EXPECTED OUTCOME**: Test PASSES (confirms baseline behavior to preserve)
  - Mark task complete when tests pass on unfixed code
  - _Requirements: 3.1, 3.2, 3.3_

- [~] 9. Write preservation tests for Bottom Navigation Functionality
  - **Property 2: Preservation** - Bottom Navigation Tab Switching and State
  - **IMPORTANT**: Follow observation-first methodology - run on UNFIXED code first
  - Observe: Tapping navigation items switches screens, active tab is highlighted, state is preserved
  - Create test file `test/screens/main/main_scaffold_navigation_test.dart`
  - Test that tapping "Home" icon shows HomeScreen
  - Test that tapping "Latihan" icon shows WorkoutListScreen
  - Test that tapping "Makan" icon shows MealListScreen
  - Test that tapping "Progress" icon shows ProgressScreen
  - Test that active tab is highlighted correctly
  - Test that IndexedStack preserves screen state when switching tabs
  - Test that navigation works on different screen sizes (320, 375, 414)
  - Run test on UNFIXED code with `flutter test test/screens/main/main_scaffold_navigation_test.dart`
  - **EXPECTED OUTCOME**: Test PASSES (confirms navigation works correctly)
  - Mark task complete when tests pass on unfixed code
  - _Requirements: 3.4, 3.5, 3.6_

- [~] 10. Write preservation tests for Onboarding Flow
  - **Property 2: Preservation** - Onboarding Carousel and Navigation
  - **IMPORTANT**: Follow observation-first methodology - run on UNFIXED code first
  - Observe: Onboarding has 3 pages, swipe works, buttons navigate correctly
  - Create test file `test/screens/splash/onboarding_flow_test.dart`
  - Test that onboarding starts at page 1
  - Test that swiping advances to next page
  - Test that "Next" button advances to next page
  - Test that "Skip" button navigates to login screen
  - Test that "Get Started" button on last page navigates to login screen
  - Test that page indicators update correctly
  - Test that all 3 pages display correct content (title, description, image)
  - Run test on UNFIXED code with `flutter test test/screens/splash/onboarding_flow_test.dart`
  - **EXPECTED OUTCOME**: Test PASSES (confirms onboarding flow works)
  - Mark task complete when tests pass on unfixed code
  - _Requirements: 3.7, 3.8_

- [~] 11. Write preservation tests for Statistics Card Data Display
  - **Property 2: Preservation** - Statistics Card Shows Correct Data
  - **IMPORTANT**: Follow observation-first methodology - run on UNFIXED code first
  - Observe: Statistics card displays duration, sets, reps, calories correctly
  - Create test file `test/widgets/statistics_card_test.dart`
  - Test that statistics card displays correct duration (e.g., "28 mnt")
  - Test that statistics card displays correct sets (e.g., "16 set")
  - Test that statistics card displays correct reps (e.g., "156 reps")
  - Test that statistics card displays correct calories (e.g., "245 kkal")
  - Test that card styling matches design system (colors, fonts, spacing)
  - Test that card renders on medium screen (375x667) without issues
  - Run test on UNFIXED code with `flutter test test/widgets/statistics_card_test.dart`
  - **EXPECTED OUTCOME**: Test PASSES (confirms data display is correct)
  - Mark task complete when tests pass on unfixed code
  - _Requirements: 3.9_

- [~] 12. Write preservation tests for Other Screens Functionality
  - **Property 2: Preservation** - All Other Screens Work Correctly
  - **IMPORTANT**: Follow observation-first methodology - run on UNFIXED code first
  - Observe: Home, Meal, Progress, Profile screens render and function correctly
  - Create test file `test/screens/general_screens_test.dart`
  - Test that HomeScreen renders without errors on medium screen (375x667)
  - Test that MealListScreen renders without errors on medium screen
  - Test that ProgressScreen renders without errors on medium screen
  - Test that ProfileScreen renders without errors on medium screen
  - Test that basic interactions work (taps, scrolls) on each screen
  - Test that data displays correctly on each screen
  - Test that navigation from each screen works
  - Run test on UNFIXED code with `flutter test test/screens/general_screens_test.dart`
  - **EXPECTED OUTCOME**: Test PASSES (confirms screens work on medium devices)
  - Mark task complete when tests pass on unfixed code
  - _Requirements: 3.10, 3.11, 3.12_

## Phase 4: Implementation - Apply Fixes

- [ ] 13. Fix Timeline Slider Removal in SetupGoalScreen

  - [x] 13.1 Remove timeline slider and calorie info card
    - Open file `lib/screens/setup/setup_goal_screen.dart`
    - Locate and remove the "TIMELINE CARD" section (timeline slider widget)
    - Locate and remove the "CALORIE INFO CARD" section
    - Remove `_timelineWeeks` state variable declaration
    - Remove `_calorieAdjustment` getter method
    - Keep goal selection cards (Turunkan Berat, Jaga Berat, Naikkan Massa Otot)
    - Keep target weight input (conditional on goal selection)
    - Update comments to reflect ML-determined timeline
    - Verify code compiles with `flutter analyze lib/screens/setup/setup_goal_screen.dart`
    - _Bug_Condition: isBugCondition(input) where input.screen == 'SetupGoalScreen' AND input.hasTimelineSlider_
    - _Expected_Behavior: SetupGoalScreen renders without timeline slider, ML determines timeline_
    - _Preservation: Goal selection, target weight input, navigation to next step must work_
    - _Requirements: 2.1, 3.1, 3.2, 3.3_

  - [~] 13.2 Verify timeline exploration test now passes
    - **Property 1: Expected Behavior** - Timeline Slider Removed Successfully
    - **IMPORTANT**: Re-run the SAME test from task 3 - do NOT write a new test
    - Run test with `flutter test test/screens/setup/setup_goal_screen_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (timeline slider no longer exists)
    - If test fails, debug and fix the implementation
    - _Requirements: 2.1_

  - [~] 13.3 Verify setup wizard preservation tests still pass
    - **Property 2: Preservation** - Setup Wizard Flow Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 8 - do NOT write new tests
    - Run test with `flutter test test/screens/setup/setup_wizard_flow_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (no regressions in wizard flow)
    - Verify goal selection still works
    - Verify target weight input still appears conditionally
    - Verify navigation to next step still works
    - If any test fails, fix the implementation to preserve behavior
    - _Requirements: 3.1, 3.2, 3.3_

- [ ] 14. Fix Bottom Navigation Spacing in MainScaffold

  - [x] 14.1 Add BottomNavigationBarType.fixed
    - Open file `lib/screens/main/main_scaffold.dart`
    - Locate BottomNavigationBar widget
    - Add property `type: BottomNavigationBarType.fixed`
    - Verify all navigation items have consistent icon sizes
    - Verify label styling is consistent across all items
    - Verify code compiles with `flutter analyze lib/screens/main/main_scaffold.dart`
    - _Bug_Condition: isBugCondition(input) where input.screen == 'MainScaffold' AND input.hasUnevenSpacing_
    - _Expected_Behavior: BottomNavigationBar has even spacing for all items_
    - _Preservation: Navigation functionality, active tab highlighting, screen switching must work_
    - _Requirements: 2.6, 2.7, 3.4, 3.5, 3.6_

  - [~] 14.2 Verify bottom navigation exploration test now passes
    - **Property 1: Expected Behavior** - Even Navigation Spacing
    - **IMPORTANT**: Re-run the SAME test from task 5 - do NOT write a new test
    - Run test with `flutter test test/screens/main/main_scaffold_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (spacing is now even)
    - If test fails, debug and fix the implementation
    - _Requirements: 2.6, 2.7_

  - [~] 14.3 Verify navigation preservation tests still pass
    - **Property 2: Preservation** - Navigation Functionality Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 9 - do NOT write new tests
    - Run test with `flutter test test/screens/main/main_scaffold_navigation_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (navigation still works correctly)
    - Verify tab switching works
    - Verify active tab highlighting works
    - Verify screen state is preserved
    - If any test fails, fix the implementation to preserve behavior
    - _Requirements: 3.4, 3.5, 3.6_

- [ ] 15. Fix Statistics Card Overflow Errors

  - [x] 15.1 Apply Flexible/Expanded/FittedBox fixes to statistics cards
    - Open file `lib/screens/workout/workout_session_detail_screen.dart`
    - Locate statistics card Row widget with duration, sets, reps, calories
    - Wrap each Text widget in statistics row with Flexible widget
    - Wrap each Flexible child with FittedBox(fit: BoxFit.scaleDown)
    - Add `overflow: TextOverflow.ellipsis` to Text widgets as fallback
    - Ensure Column uses `mainAxisSize: MainAxisSize.min`
    - Test rendering on small screen (320x568) in debug mode
    - Verify no overflow errors appear
    - Search for other screens with similar statistics cards using `grep -r "statistics" lib/screens/`
    - Apply same fix pattern to any other screens with statistics cards
    - Verify code compiles with `flutter analyze lib/screens/workout/`
    - _Bug_Condition: isBugCondition(input) where input.hasOverflowError AND input.errorType == 'BOTTOM OVERFLOWED'_
    - _Expected_Behavior: Statistics cards render without overflow on all screen sizes_
    - _Preservation: Statistics data display, card styling, tap interactions must work_
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 3.9_

  - [~] 15.2 Verify statistics card exploration test now passes
    - **Property 1: Expected Behavior** - No Overflow Errors
    - **IMPORTANT**: Re-run the SAME test from task 4 - do NOT write a new test
    - Run test with `flutter test test/screens/workout/workout_session_detail_screen_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (no overflow errors on small screen)
    - If test fails, debug and fix the Flexible/FittedBox implementation
    - _Requirements: 2.2, 2.3, 2.4, 2.5_

  - [~] 15.3 Verify statistics card preservation tests still pass
    - **Property 2: Preservation** - Statistics Data Display Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 11 - do NOT write new tests
    - Run test with `flutter test test/widgets/statistics_card_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (data still displays correctly)
    - Verify duration, sets, reps, calories display correctly
    - Verify card styling is unchanged
    - If any test fails, fix the implementation to preserve behavior
    - _Requirements: 3.9_

- [ ] 16. Fix Onboarding Text Responsiveness

  - [x] 16.1 Implement responsive image ratios and text sizing
    - Open file `lib/screens/splash/onboarding_screen.dart`
    - Locate image ratio calculation in `_OnboardingPage` widget
    - Replace fixed ratio with responsive breakpoints:
      - screenHeight < 600: imageRatio = 0.35
      - screenHeight < 700: imageRatio = 0.40
      - screenHeight < 800: imageRatio = 0.45
      - screenHeight >= 800: imageRatio = 0.50
    - Locate title text widget
    - Add responsive font size calculation:
      - screenHeight < 600: titleFontSize = 28.0
      - screenHeight < 700: titleFontSize = 32.0
      - screenHeight >= 700: titleFontSize = 36.0
    - Apply titleFontSize to title TextStyle
    - Locate description text widget
    - Add responsive font size for description (baseSize * 0.9 for small screens)
    - Ensure text section has proper padding using MediaQuery
    - Add SingleChildScrollView if text section might overflow
    - Test on small screen (320x568) in debug mode
    - Verify title and description are fully visible
    - Verify code compiles with `flutter analyze lib/screens/splash/onboarding_screen.dart`
    - _Bug_Condition: isBugCondition(input) where input.screen == 'OnboardingScreen' AND input.textIsCutOff_
    - _Expected_Behavior: Onboarding text is fully visible and readable on all screen sizes_
    - _Preservation: Onboarding carousel, page navigation, buttons must work_
    - _Requirements: 2.8, 2.9, 2.10, 2.11, 3.7, 3.8_

  - [~] 16.2 Verify onboarding exploration test now passes
    - **Property 1: Expected Behavior** - Text Fully Visible on Small Screens
    - **IMPORTANT**: Re-run the SAME test from task 6 - do NOT write a new test
    - Run test with `flutter test test/screens/splash/onboarding_screen_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (text is fully visible on 320x568)
    - If test fails, adjust responsive breakpoints and font sizes
    - _Requirements: 2.8, 2.9, 2.10, 2.11_

  - [~] 16.3 Verify onboarding preservation tests still pass
    - **Property 2: Preservation** - Onboarding Flow Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 10 - do NOT write new tests
    - Run test with `flutter test test/screens/splash/onboarding_flow_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (carousel and navigation still work)
    - Verify swipe navigation works
    - Verify "Next", "Skip", "Get Started" buttons work
    - Verify page indicators update correctly
    - If any test fails, fix the implementation to preserve behavior
    - _Requirements: 3.7, 3.8_

- [ ] 17. Apply Responsive Utilities to All Key Screens

  - [~] 17.1 Update HomeScreen with responsive utilities
    - Open file `lib/screens/home/home_screen.dart`
    - Import ResponsiveUtils: `import 'package:heltigo/utils/responsive_utils.dart';`
    - Replace hardcoded padding with `ResponsiveUtils.responsivePadding(context, small: EdgeInsets.all(12), medium: EdgeInsets.all(16), large: EdgeInsets.all(24))`
    - Replace hardcoded font sizes with `ResponsiveUtils.responsiveFontSize(context, baseSize)`
    - Add max-width constraint for large screens if needed (e.g., `ConstrainedBox(constraints: BoxConstraints(maxWidth: 600))`)
    - Test on small (320x568), medium (375x667), large (414x896) screens
    - Verify no overflow errors
    - Verify layout looks good on all sizes
    - Verify code compiles with `flutter analyze lib/screens/home/home_screen.dart`
    - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18, 2.19, 3.10_

  - [~] 17.2 Update WorkoutListScreen with responsive utilities
    - Open file `lib/screens/workout/workout_list_screen.dart`
    - Import ResponsiveUtils
    - Replace hardcoded padding with responsive padding
    - Replace hardcoded font sizes with responsive font sizes
    - Apply responsive card sizing (card height, width based on screen size)
    - Ensure ListView or GridView adapts to screen size
    - Test on small, medium, large screens
    - Verify no overflow errors
    - Verify code compiles with `flutter analyze lib/screens/workout/workout_list_screen.dart`
    - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18, 2.19, 3.10_

  - [~] 17.3 Update MealListScreen with responsive utilities
    - Open file `lib/screens/meal/meal_list_screen.dart`
    - Import ResponsiveUtils
    - Replace hardcoded padding with responsive padding
    - Replace hardcoded font sizes with responsive font sizes
    - Apply responsive card sizing for meal cards
    - Ensure meal list adapts to screen size
    - Test on small, medium, large screens
    - Verify no overflow errors
    - Verify code compiles with `flutter analyze lib/screens/meal/meal_list_screen.dart`
    - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18, 2.19, 3.10_

  - [~] 17.4 Update ProgressScreen with responsive utilities
    - Open file `lib/screens/progress/progress_screen.dart`
    - Import ResponsiveUtils
    - Replace hardcoded padding with responsive padding
    - Replace hardcoded font sizes with responsive font sizes
    - Apply responsive chart sizing (chart height based on screen size)
    - Ensure progress cards adapt to screen size
    - Test on small, medium, large screens
    - Verify no overflow errors
    - Verify code compiles with `flutter analyze lib/screens/progress/progress_screen.dart`
    - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18, 2.19, 3.10_

  - [~] 17.5 Update SetupGoalScreen with responsive utilities
    - Open file `lib/screens/setup/setup_goal_screen.dart`
    - Import ResponsiveUtils
    - Replace hardcoded padding with responsive padding
    - Replace hardcoded font sizes with responsive font sizes
    - Apply responsive card sizing for goal selection cards
    - Test on small, medium, large screens
    - Verify no overflow errors
    - Verify code compiles with `flutter analyze lib/screens/setup/setup_goal_screen.dart`
    - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18, 2.19, 3.1_

  - [~] 17.6 Verify general responsiveness exploration test now passes
    - **Property 1: Expected Behavior** - All Screens Responsive on Small Devices
    - **IMPORTANT**: Re-run the SAME test from task 7 - do NOT write a new test
    - Run test with `flutter test test/responsiveness/general_responsiveness_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (no overflow on any screen)
    - If test fails, identify which screens still have issues and fix them
    - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17, 2.18_

  - [~] 17.7 Verify other screens preservation tests still pass
    - **Property 2: Preservation** - All Screens Function Correctly
    - **IMPORTANT**: Re-run the SAME tests from task 12 - do NOT write new tests
    - Run test with `flutter test test/screens/general_screens_test.dart`
    - **EXPECTED OUTCOME**: Test PASSES (all screens still work correctly)
    - Verify HomeScreen functionality is preserved
    - Verify MealListScreen functionality is preserved
    - Verify ProgressScreen functionality is preserved
    - Verify ProfileScreen functionality is preserved
    - If any test fails, fix the implementation to preserve behavior
    - _Requirements: 3.10, 3.11, 3.12_

## Phase 5: Comprehensive Testing and Validation

- [~] 18. Run full test suite and verify all tests pass
  - Run all unit tests with `flutter test test/utils/`
  - Run all widget tests with `flutter test test/screens/ test/widgets/`
  - Run all responsiveness tests with `flutter test test/responsiveness/`
  - Verify all exploration tests (Property 1) now pass
  - Verify all preservation tests (Property 2) still pass
  - Fix any failing tests by adjusting implementation
  - Document test results in a summary file
  - _Requirements: All requirements 2.1-2.19, 3.1-3.13_

- [x] 19. Run flutter analyze and fix all warnings/errors
  - Run `flutter analyze` on entire codebase
  - Verify zero errors related to overflow
  - Verify zero warnings related to layout issues
  - Fix any linting issues found
  - Fix any type errors or null safety issues
  - Verify all imports are correct
  - Verify no unused variables or dead code
  - Run `flutter analyze` again to confirm all issues resolved
  - Document analyze results (should be clean)
  - _Requirements: 3.13_

- [~] 20. Build application for iOS and Android
  - Run `flutter build apk --debug` for Android
  - Verify build succeeds without errors
  - Verify no build warnings related to UI/layout
  - Run `flutter build ios --debug --no-codesign` for iOS (if on macOS)
  - Verify build succeeds without errors
  - Document build results
  - _Requirements: 3.13_

- [~] 21. Manual testing on multiple device sizes
  - Test on small device (iPhone SE simulator or 320x568 emulator)
    - Open SetupGoalScreen → Verify no timeline slider
    - Open workout session detail → Verify no overflow errors
    - View bottom navigation → Verify even spacing
    - View onboarding → Verify text is fully visible
    - Navigate through all main screens → Verify responsive layouts
  - Test on medium device (iPhone 12 simulator or 375x667 emulator)
    - Repeat all tests above
    - Verify layouts look good and proportional
  - Test on large device (iPhone Pro Max simulator or 414x896 emulator)
    - Repeat all tests above
    - Verify layouts don't stretch too much
    - Verify max-width constraints work if applied
  - Test dark mode on all device sizes
    - Switch to dark mode in device settings
    - Verify no layout breaks
    - Verify all fixes still work
  - Test with large system font size (accessibility)
    - Enable large text in device accessibility settings
    - Verify text scales properly
    - Verify no overflow errors with large text
  - Document all manual testing results
  - Take screenshots of key screens on different sizes
  - _Requirements: All requirements 2.1-2.19, 3.1-3.13_

## Phase 6: Final Checkpoint

- [~] 22. Final verification and documentation
  - Verify all 21 previous tasks are completed
  - Verify all exploration tests (Property 1) pass
  - Verify all preservation tests (Property 2) pass
  - Verify `flutter analyze` shows zero errors
  - Verify builds succeed for iOS and Android
  - Verify manual testing completed on 3+ device sizes
  - Create summary document with:
    - List of all bugs fixed
    - List of all files modified
    - Test coverage summary
    - Screenshots of before/after (if available)
    - Known limitations or edge cases
  - Ask user if any questions or issues arise
  - Mark bugfix complete when all verifications pass
  - _Requirements: All requirements 2.1-2.19, 3.1-3.13_
