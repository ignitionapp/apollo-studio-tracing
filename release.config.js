module.exports = {
  branches: ['master', { name: 'beta', prerelease: true }],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    [
      'semantic-release-rubygem',
      {
        updateGemfileLock: 'bundle exec appraisal install',
      },
    ],
    [
      '@semantic-release/git',
      {
        assets: [
          'CHANGELOG.md',
          'gemfiles/*.lock',
          'Gemfile.lock',
          'lib/apollo-studio-tracing/version.rb',
        ],
      },
    ],
    '@semantic-release/github',
  ],
}
