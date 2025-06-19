const {
  withPlugins,
  withMainApplication,
  withAppBuildGradle,
  withSettingsGradle,
  withGradleProperties,
} = require('@expo/config-plugins');
const path = require('path');

const withDojahKyc = config => {
  return withPlugins(config, [
    // withMainApplicationModification,
    // withAppBuildGradleModification,
    // withSettingsGradleModification,
    // withGradlePropertiesModification,
  ]);
};

function withMainApplicationModification(config) {
  return withMainApplication(config, config => {
    if (!config.modResults.contents.includes('com.dojahkyc.rn.DojahKycPackage()')) {
      config.modResults.contents = config.modResults.contents.replace(
        'packages.add(new MyReactNativePackage())',
        `packages.add(new MyReactNativePackage())\n            packages.add(com.dojahkyc.rn.DojahKycPackage())`
      );
    }
    return config;
  });
}

function withAppBuildGradleModification(config) {
  return withAppBuildGradle(config, config => {
    if (!config.modResults.contents.includes("project(':dojah-kyc-sdk-react_native')")) {
      config.modResults.contents += `
        dependencies {
            implementation project(':dojah-kyc-sdk-react_native')
        }
      `;
    }
    return config;
  });
}

function withSettingsGradleModification(config) {
  return withSettingsGradle(config, config => {
    if (!config.modResults.contents.includes("include ':dojah-kyc-sdk-react_native'")) {
      config.modResults.contents += `
        include ':dojah-kyc-sdk-react_native'
        project(':dojah-kyc-sdk-react_native').projectDir = new File(rootProject.projectDir, '../node_modules/dojah-kyc-sdk-react_native/android')
      `;
    }
    return config;
  });
}

function withGradlePropertiesModification(config) {
  return withGradleProperties(config, (config) => {
    if (!config.modResults) {
      config.modResults = [];
    }

    // Add new entries
    config.modResults.push(
      [{
        key: 'org.gradle.jvmargs',
        value:
          '-Xmx4096m -XX:MaxMetaspaceSize=512m -XX:MaxPermSize=1024m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8',
      },
      {
        key: 'android.enableJetifier',
        value: 'true',
      }]
    );

    return config;
  });
}



module.exports = withDojahKyc;
