const { magic } = require('./magic')

const handler = async (event) => {
  if (!event) {
    throw new Error('No event was supplied')
  }

  const { queryStringParameters: { number } } = event

  if (!number) {
    throw new Error('Number parameter not specified')
  }

  const parsedNum = parseInt(number)

  if (!parsedNum) {
    throw new Error('Number parameter is not a number')
  }

  const result = parsedNum + magic() // Add the magic

  return {
    isBase64Encoded: false,
    statusCode: 200,
    body: JSON.stringify({ result })
  }
}

module.exports = {
  handler
}
