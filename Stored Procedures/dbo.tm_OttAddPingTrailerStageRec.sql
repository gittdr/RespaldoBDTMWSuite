SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_OttAddPingTrailerStageRec]	
		@TrailerID				AS VARCHAR(8),
		@TrailerSCAC			AS VARCHAR(4),
		@RequestedBy			AS VARCHAR(20)

AS

-- =============================================================================
-- Stored Proc: tm_OttAddPingTrailerStageRec
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.05.12
-- Description:
--      This procedure adds a record to the tblOttPingTrailerStage table.
--		It has been designed to be called by a TotalMail form for enterging a 
--      trailer ping request into the staging table for Omnitracs. 
--      
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @TrailerID			VARCHAR(8)
--		002 - @TrailerSCAC			VARCHAR(4)
--		003 - @RequestedBy			VARCHAR(20)
--
--      Outputs:
--      ------------------------------------------------------------------------
--		None
--
-- =============================================================================
-- Modification Log:
-- PTS 77420 - VMS - 2014.05.12 - New
-- 
-- =============================================================================
-- Used for testing proc
--	EXEC tm_OttAddPingTrailerStageRec '', '', ''
-- =============================================================================

BEGIN

	DECLARE 
		@RecStatCode	AS INTEGER,
		@CreatedOn		AS DATETIME,
		@CreatedBy		AS VARCHAR (20),
		@UpdatedOn		AS DATETIME,
		@UpdatedBy		AS VARCHAR (20)

	----------------------------------------------------------------------------
	SET @RecStatCode = 0			

	-- These are the RecStatCode values that will be used per the QCTrailerTracks
	-- application modMain.vb.
	--    Public Enum eThisRecStat
	--        NewEntry = 0
	--        Processing = 1
	--        Ok = 2			(aka Processed)
	--        Err = 5
	--        ManualHold = 9
	--    End Enum
	----------------------------------------------------------------------------
	-- CreatedBy and UpdatedBy will be the same for this new record.
	SET @CreatedOn = GETDATE()
	SET @CreatedBy = @RequestedBy
	SET @UpdatedOn = GETDATE()
	SET @UpdatedBy = @RequestedBy
	----------------------------------------------------------------------------
	INSERT INTO [dbo].[tblOttPingTrailerStage] (
		TrailerID,
		TrailerSCAC,
		RecStatCode,
		CreatedOn,
		CreatedBy,
		UpdatedOn,
		UpdatedBy
		)
	VALUES (
		@TrailerID,
		@TrailerSCAC,
		@RecStatCode,
		@CreatedOn,
		@CreatedBy,
		@UpdatedOn,
		@UpdatedBy
		)
END	

GO
GRANT EXECUTE ON  [dbo].[tm_OttAddPingTrailerStageRec] TO [public]
GO
