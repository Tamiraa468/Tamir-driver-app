const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require("nativewind/metro");

const config = getDefaultConfig(__dirname);

config.resolver.blockList = [
  /\/benchmarks\/.*/,
  /\/security-tests\/.*/,
  /\/analysis\/.*/,
  /\/load_test\/.*/,
  /\/results\/.*/,
];

module.exports = withNativeWind(config, { input: "./global.css" });
