/* eslint-env jest */
const {
  magic
} = require('./index')

describe('Test Suite 1', () => {
  test('Ensure 42 is the magic', () => {
    expect.assertions(1)
    return expect(magic()).toEqual(42)
  })
})
