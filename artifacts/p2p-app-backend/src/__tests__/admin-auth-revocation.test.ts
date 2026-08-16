/**
 * Targeted tests: admin-token revocation in guardRole
 *
 * Verifies that:
 *   1. An expired admin JWT is denied (401)
 *   2. A valid admin JWT whose DB role has been demoted is denied (403)
 *   3. A valid admin JWT whose account is suspended (isDeleted) is denied (403)
 *   4. A valid admin JWT with current DB role "admin" and not suspended passes (calls next)
 *
 * These tests are unit tests of the guardRole middleware — no HTTP server or
 * real database connection required; UserModel.findOne is mocked via jest.mock.
 */

// ── Mocks ──────────────────────────────────────────────────────────────────
jest.mock("../modules/user/user.model", () => ({
  UserModel: { findOne: jest.fn() },
}));

jest.mock("../utils/sendResponse", () =>
  jest.fn((res: any, payload: any) => {
    res.statusCode = payload.statusCode;
    res._payload = payload;
  })
);

// ── Imports (after mocks) ──────────────────────────────────────────────────
import jwt from "jsonwebtoken";
import { guardRole } from "../middlewares/roleGuard";
import { UserModel } from "../modules/user/user.model";
import sendResponse from "../utils/sendResponse";

const mockUserModel = UserModel as jest.Mocked<typeof UserModel>;
const mockSendResponse = sendResponse as jest.MockedFunction<typeof sendResponse>;

// Use a deterministic secret for test tokens
const TEST_SECRET = "test-secret-do-not-use-in-production";
const originalEnv = process.env;

function makeAdminToken(overrides: jwt.SignOptions = {}): string {
  return jwt.sign(
    { id: "admin-user-id", role: "admin", email: "admin@test.com" },
    TEST_SECRET,
    { expiresIn: "1h", ...overrides }
  );
}

function makeReq(token?: string): any {
  return {
    headers: token ? { authorization: `Bearer ${token}` } : {},
  };
}

function makeRes(): any {
  return {
    statusCode: 200,
    _payload: null,
  };
}

// Wire test JWT_SECRET into the process env
beforeEach(() => {
  process.env = { ...originalEnv, JWT_SECRET: TEST_SECRET };
});

afterEach(() => {
  process.env = originalEnv;
});

// ── Test suite ─────────────────────────────────────────────────────────────

describe("guardRole admin-token revocation", () => {
  const middleware = guardRole(["admin"]);

  test("1. expired admin JWT → 401", async () => {
    const expiredToken = makeAdminToken({ expiresIn: -1 }); // already expired
    const req = makeReq(expiredToken);
    const res = makeRes();
    const next = jest.fn();

    await middleware(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(mockSendResponse).toHaveBeenCalledWith(
      res,
      expect.objectContaining({ statusCode: 401 })
    );
  });

  test("2. valid admin JWT but DB role demoted to 'user' → 403", async () => {
    (mockUserModel.findOne as jest.Mock).mockResolvedValueOnce({
      _id: "admin-user-id",
      role: "user", // demoted
      isDeleted: false,
      isVerified: true,
    });

    const req = makeReq(makeAdminToken());
    const res = makeRes();
    const next = jest.fn();

    await middleware(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(mockSendResponse).toHaveBeenCalledWith(
      res,
      expect.objectContaining({ statusCode: 403 })
    );
  });

  test("3. valid admin JWT but account suspended (isDeleted: true) → 403", async () => {
    (mockUserModel.findOne as jest.Mock).mockResolvedValueOnce({
      _id: "admin-user-id",
      role: "admin",
      isDeleted: true, // suspended
      isVerified: true,
    });

    const req = makeReq(makeAdminToken());
    const res = makeRes();
    const next = jest.fn();

    await middleware(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(mockSendResponse).toHaveBeenCalledWith(
      res,
      expect.objectContaining({ statusCode: 403 })
    );
  });

  test("4. valid admin JWT, DB role still 'admin', not suspended → allowed", async () => {
    (mockUserModel.findOne as jest.Mock).mockResolvedValueOnce({
      _id: "admin-user-id",
      role: "admin",
      isDeleted: false,
      isVerified: true,
    });

    const req = makeReq(makeAdminToken());
    const res = makeRes();
    const next = jest.fn();

    await middleware(req, res, next);

    expect(next).toHaveBeenCalledTimes(1);
    expect(mockSendResponse).not.toHaveBeenCalled();
  });

  test("5. no token at all → 401", async () => {
    const req = makeReq(undefined);
    const res = makeRes();
    const next = jest.fn();

    await middleware(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(mockSendResponse).toHaveBeenCalledWith(
      res,
      expect.objectContaining({ statusCode: 401 })
    );
  });
});
