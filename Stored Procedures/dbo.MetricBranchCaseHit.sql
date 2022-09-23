SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricBranchCaseHit](@BranchText varchar(255) )
AS
	SET NOCOUNT ON

	-- SET @BranchCase = '221. OvernightBackfillReadyYN = ""N""'
	DECLARE @BranchCase varchar(255)
	SELECT @BranchCase = LEFT(@BranchText, CHARINDEX('.', @BranchText)-1)	

	IF ISNUMERIC(@BranchCase) = 1
	BEGIN
		IF NOT EXISTS(SELECT * FROM dbo.MetricBranchCasesForQAOnly WHERE BranchText = @BranchText)
			INSERT INTO dbo.MetricBranchCasesForQAOnly (BranchCase, BranchText, hits) SELECT CONVERT(int, @BranchCase), @BranchText, 1
		ELSE
			UPDATE dbo.MetricBranchCasesForQAOnly SET hits = hits + 1, dt_last = GETDATE() WHERE BranchText = @BranchText
	END
		
GO
GRANT EXECUTE ON  [dbo].[MetricBranchCaseHit] TO [public]
GO
