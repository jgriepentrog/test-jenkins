/* eslint-env jest */
const {
  handler
} = require('./index')

describe('Test Successes', () => {
  test('Ensure the magic is added to a number', () => {
    expect.assertions(1)
    return expect(handler({ queryStringParameters: { number: 7 } })).resolves.toEqual({
      isBase64Encoded: false,
      statusCode: 200,
      body: '{"result":49}'
    })
  })
})

describe('Test Failures', () => {
  test('Ensure an error is thrown with no event', () => {
    expect.assertions(1)
    return expect(handler(null)).rejects.toThrow()
  })
  test('Ensure an error is thrown with no number in the event', () => {
    expect.assertions(1)
    return expect(handler({ queryStringParameters: {} })).rejects.toThrow()
  })
  test('Ensure the magic isn\'t added when not a number', () => {
    expect.assertions(1)
    return expect(handler({ queryStringParameters: { number: 'hi' } })).rejects.toThrow()
  })
})
