SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Upd_QHOSLoads2_Rec] 
							(
							 @LoadID				AS INT,
							 @DriverID				AS VARCHAR(8),
							 @LoadTime				AS DATETIME,
							 @UnloadTime			AS DATETIME , 
							 @TrailerIDs			AS VARCHAR(254),
 							 @TractorID				AS VARCHAR(8),
							 @LoadDescriptionType	AS INT ,
							 @LoadDescription		AS VARCHAR(254)
							 )

AS

-- =============================================================================
-- Stored Proc: [dbo].[tm_Upd_QHOSLoads2_Rec]
-- Author     :	Sensabaugh, Virgil
-- Create date: 2012.09.25
-- Description:
--		This stored procedure will update the indicated record in tblQHOSLoads2.
--		The LoadID, DriverID and TractorID will be used to find the record that
--      needs to be modified.  All of these pieces of information need to be
--      present to do an update.  The validity of the three key data pieces 
--      should be checked by the calling function/procedure.
--      
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @LoadID				AS VARCHAR(80),
--		002 - @DriverID				AS VARCHAR(8),
--		003 - @LoadTime				AS DATETIME,
--		004 - @UnloadTime			AS DATETIME , 
--		005 - @TrailerIDs			AS VARCHAR(254),
--		006 - @TractorID			AS VARCHAR(8),
--		007 - @LoadDescriptionType	AS INT ,
--		008 - @LoadDescription		AS VARCHAR(254)
--
--      Outputs:
--      ------------------------------------------------------------------------
--		None - just the return value 
-- =============================================================================
-- Modification Log:
--
-- 2014.09.26 - VMS - PTS 82928 - Add LoadTime to UPDATE statement.
-- =============================================================================

BEGIN
	----------------------------------------------------------------------------
	-- Verify that the record to modified exists in table tblQHOSLoads2
	IF EXISTS( SELECT LoadID
			    FROM dbo.tblQHOSLoads2 
			   WHERE LoadID = @LoadID)
		------------------------------------------------------------------------
		-- Record found for updating
		BEGIN

			UPDATE dbo.tblQHOSLoads2

					SET LoadTime			= @LoadTime,
						UnloadTime			= @UnloadTime, 
						TrailerIDs			= @TrailerIDs,
						TractorID			= @TractorID ,
						LoadDescriptionType	= @LoadDescriptionType ,
						LoadDescription		= @LoadDescription ,
						UpdatedOn			= GETDATE()
			 WHERE 
					LoadID = @LoadID

		END

END

GO
GRANT EXECUTE ON  [dbo].[tm_Upd_QHOSLoads2_Rec] TO [public]
GO
