import { AppRegistry } from 'react-native';
import App from './src/App';
import { name as appName } from './app.json';
// import { initializeDojahIOS } from 'react-native-dojah_kyc';

// initializeDojahIOS(appName);
AppRegistry.registerComponent(appName, () => App);
