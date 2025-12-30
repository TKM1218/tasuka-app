exports.handler = async (event) => {
  console.log("notify lambda invoked", JSON.stringify(event));

  return {
    statusCode: 200,
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify({
      ok: true,
    }),
  };
};
