import * as React from 'react';

import {
  StyleSheet,
  View,
  Button,
  TextInput,
  NativeEventEmitter,
  NativeModules,
  Platform,
} from 'react-native';
import { launchDojahKyc } from 'dojah-kyc-sdk-react_native';
// import { name as appName } from '../app.json';

// import { getIdHistory } from 'dojah-kyc-sdk-react_native';

// Only create event emitter on iOS (Android uses promises, not events)
const eventEmitter =
  Platform.OS === 'ios' ? new NativeEventEmitter(NativeModules.DojahKyc) : null;

export default function App() {
  // const [result, setResult] = React.useState<string | null>();//65ae97f4afee1c0040c9df6a
  const [widgetId, setWidgetId] = React.useState('6687b43b97a6dd0040ab4e5d');
  const [email, setEmail] = React.useState('');
  const [referenceId, setReferenceId] = React.useState('');

  React.useEffect(() => {
    // Register event listener only on iOS to prevent "no listeners" warning
    // Android uses promises instead of events
    if (Platform.OS === 'ios' && eventEmitter) {
      const subscription = eventEmitter.addListener('onChange', (event) => {
        console.log('Dojah onChange event:', event);
      });

      // Cleanup listener on unmount
      return () => {
        subscription.remove();
      };
    }
    // Android doesn't use events, so no cleanup needed
    return undefined;
  }, []);

  const onPress = () => {
    const ref: string | null = referenceId === '' ? null : referenceId;
    const mail: string | null = email === '' ? null : email;

    console.log('ref: ', ref);
    console.log('mail: ', mail);
    console.log('widgetId: ', widgetId);

    // Define individual data objects
    const userData = {
      // firstName: 'John',
      // lastName: 'Doe',
      // dob: '1990-01-01',
      // email: mail
    };
    const govData = {
      // bvn: 'your-bvn',
      // dl: 'your-dl',
      // nin: 'your-nin',
      // vnin: 'your-vnin'
    };
    const govId = {
      // national: 'your-national-id',
      // passport: 'your-passport-id',
      // dl: 'your-dl-id',
      // voter: 'your-voter-id',
      // nin: 'your-nin-id',
      // others: 'your-others-id'
    };
    const location = {
      // latitude: 'your-latitude',
      // longitude: 'your-longitude'
    };
    const businessData = {
      // cac: 'your-cac'
    };
    const address = 'No 12 Street, Atilogun, Lagos, Nigeria';
    const metadata = {
      key1: 'value1',
      key2: 'value2',
    };

    // Build extraData object as prescribed by the docs
    // Structure: { userData, govData, govId, location, businessData, address, metadata }
    const extraData: any = {};
    if (Object.keys(userData).length > 0) extraData.userData = userData;
    if (Object.keys(govData).length > 0) extraData.govData = govData;
    if (Object.keys(govId).length > 0) extraData.govId = govId;
    if (Object.keys(location).length > 0) extraData.location = location;
    if (Object.keys(businessData).length > 0)
      extraData.businessData = businessData;
    if (address) extraData.address = address;
    if (Object.keys(metadata).length > 0) extraData.metadata = metadata;

    // Launch Dojah KYC with extraData object (matching docs structure)
    // DojahKycSdk.launch(widgetId, referenceId, email, { userData, govData, govId, location, businessData, address, metadata })
    launchDojahKyc(
      widgetId,
      ref,
      mail,
      Object.keys(extraData).length > 0 ? extraData : null
    ).then((result) => {
      console.log('Result: ', result);
      switch (result) {
        case 'approved':
          //kyc approved
          console.log('KYC Approved');
          break;
        case 'pending':
          //kyc pending
          console.log('KYC Pending');
          break;
        case 'failed':
          //kyc failed
          console.log('KYC Failed');
          break;
        case 'closed':
          //user has cancelled the KYC
          console.log('KYC Closed');
      }
    });
  };
  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        onChangeText={setWidgetId}
        defaultValue={widgetId}
      />
      <TextInput
        style={styles.input}
        onChangeText={setEmail}
        defaultValue={email}
        placeholder="Enter Email (Optional)"
      />
      <TextInput
        style={styles.input}
        onChangeText={setReferenceId}
        defaultValue={referenceId}
        placeholder="Reference Id(Optional)"
      />
      {/* <Text style= {styles.history}>History: {result}</Text> */}
      <View style={styles.button}>
        <Button onPress={onPress} title="Launch Dojah" />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'stretch',
    justifyContent: 'center',
    paddingHorizontal: 40,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  input: {
    height: 40,
    margin: 12,
    borderWidth: 0.8,
    borderRadius: 4,
    padding: 10,
  },
  history: {
    paddingBottom: 20,
    paddingStart: 10,
    textAlign: 'left',
  },
  button: {
    paddingHorizontal: 60,
    paddingTop: 20,
  },
});
