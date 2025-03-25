import { expect } from "chai";
import sinon from "sinon";
import pkg from "pg";
const { Pool } = pkg;
import { publishScores, getPublishedScoresForParticipant } from "../../src/models/publishedScoresModel.js";
import pool from "../../src/models/db.js";

// Enable chai-as-promised for promise assertions
import chaiAsPromised from "chai-as-promised";
import * as chai from "chai";
chai.use(chaiAsPromised);

describe("Published Scores Model", () => {
  let poolQueryStub;

  beforeEach(() => {
    poolQueryStub = sinon.stub(pool, "query");
  });

  afterEach(() => {
    sinon.restore();
  });

  describe("publishScores", () => {
    it("should publish scores successfully", async () => {
      const mockScores = [
        { judge: "FinalA", score: 9.5 },
        { judge: "FinalB", score: 9.0 },
      ];
      poolQueryStub.onFirstCall().resolves(); // DELETE call
      poolQueryStub.onSecondCall().resolves({ rows: [{ participant_id: 1, judge: "FinalA", score: 9.5, division_id: 1 }] });
      poolQueryStub.onThirdCall().resolves({ rows: [{ participant_id: 1, judge: "FinalB", score: 9.0, division_id: 1 }] });

      const result = await publishScores(1, mockScores, 1);
      expect(result).to.have.lengthOf(2);
      expect(result[0].score).to.equal(9.5);
      expect(result[1].score).to.equal(9.0);
      expect(poolQueryStub.callCount).to.equal(3);
      expect(poolQueryStub.firstCall.args[0]).to.equal("DELETE FROM published_scores WHERE participant_id = $1 AND division_id = $2");
      expect(poolQueryStub.secondCall.args[0]).to.equal("INSERT INTO published_scores (participant_id, judge, score, division_id) VALUES ($1, $2, $3, $4) RETURNING *");
    });

    it("should handle errors during publishing", async () => {
      const mockScores = [{ judge: "FinalA", score: 9.5 }];
      poolQueryStub.onFirstCall().resolves(); // DELETE call
      poolQueryStub.onSecondCall().rejects(new Error("Database error"));

      await expect(publishScores(1, mockScores, 1)).to.be.rejectedWith("Database error");
      expect(poolQueryStub.callCount).to.equal(2);
    });
  });

  describe("getPublishedScoresForParticipant", () => {
    it("should return published scores and deductions for a participant in a division", async () => {
      const mockScores = [
        { judge: "FinalA", score: 9.5 },
        { judge: "FinalB", score: 9.0 },
      ];
      const mockDeductions = [{ deduction_code: "D1" }, { deduction_code: "D2" }];
      poolQueryStub.onFirstCall().resolves({ rows: mockScores });
      poolQueryStub.onSecondCall().resolves({ rows: mockDeductions });

      const result = await getPublishedScoresForParticipant(1, 1);
      expect(result.scores).to.deep.equal(mockScores);
      expect(result.deduction_codes).to.deep.equal(["D1", "D2"]);
      expect(poolQueryStub.callCount).to.equal(2);
      expect(poolQueryStub.firstCall.args[0]).to.equal("SELECT judge, score FROM published_scores WHERE participant_id = $1 AND division_id = $2 ORDER BY published_at DESC");
      // Updated to match the actual query with consistent indentation
      expect(poolQueryStub.secondCall.args[0]).to.equal(
        `SELECT DISTINCT d.deduction_code
     FROM participant_deductions pd
     JOIN deductions d ON pd.deduction_id = d.deduction_id
     WHERE pd.participant_id = $1 AND pd.judge IN ('A1', 'A2') AND pd.division_id = $2`
      );
    });

    it("should return empty arrays if no data exists", async () => {
      poolQueryStub.onFirstCall().resolves({ rows: [] });
      poolQueryStub.onSecondCall().resolves({ rows: [] });

      const result = await getPublishedScoresForParticipant(1, 1);
      expect(result.scores).to.deep.equal([]);
      expect(result.deduction_codes).to.deep.equal([]);
      expect(poolQueryStub.callCount).to.equal(2);
    });
  });
});