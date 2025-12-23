module.exports = {
  skipFiles: ['test', 'examples'],
  istanbulReporter: ['html', 'lcov', 'text'],
  providerOptions: {
    mnemonic: process.env.MNEMONIC || 'test test test test test test test test test test test junk',
  },
  mocha: {
    grep: '@skip-on-coverage',
    invert: true,
  },
};
