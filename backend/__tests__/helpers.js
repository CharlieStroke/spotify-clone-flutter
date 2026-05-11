const mockReq = (overrides = {}) => ({
  user:    { userId: 1 },
  artist:  { artist_id: 1 },
  params:  {},
  body:    {},
  query:   {},
  headers: {},
  files:   null,
  file:    null,
  ...overrides,
});

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  return res;
};

const mockNext = () => jest.fn();

module.exports = { mockReq, mockRes, mockNext };
