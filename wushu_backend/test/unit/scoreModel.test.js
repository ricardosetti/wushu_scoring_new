import { expect } from "chai";
import sinon from "sinon";
import pkg from "pg";
const { Pool } = pkg;
import {
  getAllScores,
  addScore,
  getLatestScore,
  getScoresForParticipant,
} from "../../src/models/scoreModel.js";
import pool from "../../src/models/db.js";

// Enable chai-as-promised for promise assertions
import chaiAsPromised from "chai-as-promised";
import * as chai from "chai"; // Use namespace import for chai
chai.use(chaiAsPromised);

describe("Score Model", () => {
  let poolQueryStub;

  beforeEach(() => {
    poolQueryStub = sinon.stub(pool, "query");
  });

  afterEach(() => {
    sinon.restore();
  });

  describe("getAllScores", () => {
    it("should return all scores ordered by created_at", async () => {
      const mockScores = [
        { id: 1, participant_id: 1, judge: "A1", score: 9.5, division_id: 1, created_at: new Date() },
        { id: 2, participant_id: 2, judge: "A2", score: 9.0, division_id: 2, created_at: new Date() },
      ];
      poolQueryStub.resolves({ rows: mockScores });

      const result = await getAllScores();
      expect(result).to.deep.equal(mockScores);
      expect(poolQueryStub.calledOnce).to.be.true;
      expect(poolQueryStub.firstCall.args[0]).to.equal("SELECT * FROM scores ORDER BY created_at DESC");
    });
  });

  describe("addScore", () => {
    it("should add a score successfully", async () => {
      const mockResult = { id: 1, participant_id: 1, judge: "A1", score: 9.5, division_id: 1 };
      poolQueryStub.resolves({ rows: [mockResult] });

      const result = await addScore(1, "A1", 9.5, 1);
      expect(result).to.deep.equal(mockResult);
      expect(poolQueryStub.calledOnce).to.be.true;
      expect(poolQueryStub.firstCall.args[0]).to.equal(
        "INSERT INTO scores (participant_id, judge, score, division_id) VALUES ($1, $2, $3, $4) RETURNING *"
      );
      expect(poolQueryStub.firstCall.args[1]).to.deep.equal([1, "A1", 9.5, 1]);
    });

    it("should throw an error for invalid input", async () => {
      poolQueryStub.rejects(new Error("Database error"));
      await expect(addScore(null, "A1", 9.5, 1)).to.be.rejectedWith("Database error");
      expect(poolQueryStub.calledOnce).to.be.true; // Updated expectation since the stub is called
    });
  });

  describe("getLatestScore", () => {
    it("should return the latest score for a participant and judge", async () => {
      poolQueryStub.resolves({ rows: [{ score: 9.5 }] });

      const result = await getLatestScore(1, "A1", 1);
      expect(result).to.deep.equal({ score: 9.5 });
      expect(poolQueryStub.calledOnce).to.be.true;
      expect(poolQueryStub.firstCall.args[0]).to.equal(
        "SELECT score FROM scores WHERE participant_id = $1 AND judge = $2 AND division_id = $3 ORDER BY created_at DESC LIMIT 1"
      );
      expect(poolQueryStub.firstCall.args[1]).to.deep.equal([1, "A1", 1]);
    });

    it("should return null if no score exists", async () => {
      poolQueryStub.resolves({ rows: [] });

      const result = await getLatestScore(1, "A1", 1);
      expect(result).to.be.null;
      expect(poolQueryStub.calledOnce).to.be.true;
    });
  });

  describe("getScoresForParticipant", () => {
    it("should return all scores for a participant in a division", async () => {
      const mockScores = [
        { judge: "A1", score: 9.5 },
        { judge: "A2", score: 9.0 },
      ];
      poolQueryStub.resolves({ rows: mockScores });

      const result = await getScoresForParticipant(1, 1);
      expect(result).to.deep.equal(mockScores);
      expect(poolQueryStub.calledOnce).to.be.true;
      expect(poolQueryStub.firstCall.args[0]).to.equal(
        "SELECT judge, score FROM scores WHERE participant_id = $1 AND division_id = $2 ORDER BY created_at DESC"
      );
      expect(poolQueryStub.firstCall.args[1]).to.deep.equal([1, 1]);
    });

    it("should return an empty array if no scores exist", async () => {
      poolQueryStub.resolves({ rows: [] });

      const result = await getScoresForParticipant(1, 1);
      expect(result).to.deep.equal([]);
      expect(poolQueryStub.calledOnce).to.be.true;
    });
  });
});