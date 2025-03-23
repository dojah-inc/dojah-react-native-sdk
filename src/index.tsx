import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-dojah_kyc' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const DojahKyc = NativeModules.DojahKyc
  ? NativeModules.DojahKyc
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

/// Initialize Dojah KYC for IOS,
/// call this before your app is registered
/// the Sdk won't work on IOS without this
/// @param appName: the name of your app
// export function initializeDojahIOS(appName: string) {
// if(Platform.OS === 'ios'){
//   DojahKyc.initialize(appName);
// }
// }

export function launchDojahKyc(
  widgetId: string,
  referenceId?: string | null,
  email?: string | null
) {
  if (Platform.OS === 'ios') {
    DojahKyc.launch(widgetId, referenceId ?? '', email ?? '');
  } else {
    DojahKyc.launch(widgetId, referenceId, email);
  }
}

export function getIdHistory(): Promise<Map<string, string> | null> {
  return DojahKyc.getIdHistory();
}
