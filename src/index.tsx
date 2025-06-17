import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'dojah-kyc-sdk-react_native' doesn't seem to be linked. Make sure: \n\n` +
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

/**
 * Launches the Dojah KYC flow
 * @param widgetId - The widget ID to be used
 * @param referenceId (optional) - The reference ID to be used
 * @param email (optional) - The email to be used
 * @param userData (optional) - your user data if available
 * @param govData (optional) - your government data if available
 * @param govId (optional) - your government ID data if available
 * @param location (optional) - your location data if available
 * @param businessData (optional) - your business data if available
 * @param address (optional) - your address data if available
 * @param metadata (optional) - your metadata data if any
 * @returns - the Promise of the result
 * @throws - an error if the Dojah KYC flow fails
 * @example
 * 
 * ```typescript
 * import { launchDojahKyc } from 'dojah-kyc-sdk-react_native';
 * const widgetId = 'your-widget-id';
 * const referenceId = 'your-reference-id';
 * const email = 'your-email@example.com';
 * const userData = {
 *   firstName: 'John',
 *   lastName: 'Doe',
 *   dob: '1990-01-01',
 *   email: email
 * };
 * const govData = {
 *   bvn: 'your-bvn',
 *   dl: 'your-dl',
 *   nin: 'your-nin',
 *   vnin: 'your-vnin'
 * };
 * const govId = {
 *   national: 'your-national-id',
 *   passport: 'your-passport-id',
 *   dl: 'your-dl-id',
 *   voter: 'your-voter-id',
 *   nin: 'your-nin-id',
 *   others: 'your-others-id'
 * };
 * const location = {
 *   latitude: 'your-latitude',
 *   longitude: 'your-longitude'
 * };
 * const businessData = {
 *   cac: 'your-cac'
 * };
 * const address = 'your-address';
 * const metadata = {
 *   key1: 'value1',
 *   key2: 'value2'
 * };
 * launchDojahKyc(widgetId, referenceId, email, userData, govData, govId, location, businessData, address, metadata)
 *   .then((result) => {
 *     console.log('Result: ', result);
 *   })
 *   .catch((error) => {
 *     console.error('Error: ', error);
 *   });
 * ```
**/

export function launchDojahKyc(
  widgetId: string,
  referenceId?: string | null,
  email?: string | null,
  userData: Object | null = null,
  govData: Object | null = null,
  govId: Object | null = null,
  location: Object | null = null,
  businessData: Object | null = null,
  address: string | null = null,
  metadata: Object | null = null
): Promise<string | null> {
    return DojahKyc.launch(
      widgetId, referenceId, email, userData,
      govData, govId, location, businessData,
      address, metadata
    );
}

export function getIdHistory(): Promise<Map<string, string> | null> {
  return DojahKyc.getIdHistory();
}
