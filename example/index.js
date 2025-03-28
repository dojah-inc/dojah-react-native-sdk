import { AppRegistry } from 'react-native';
import App from './src/App';
import { name as appName } from './app.json';
// import { initializeDojahIOS } from 'dojah-kyc-sdk-react_native';

// initializeDojahIOS(appName);
AppRegistry.registerComponent(appName, () => App);
