SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_drv_hist_help]	
						@DriverSN INT,
						@MaxMessages INT

AS

/* 10/2/01 TD: Created to workaround SQL 2K Insert/RowCount issue. */
/* 05/13/11 LB: PTS 55668 - Added DispatchGroupSN to the result set */
/* 09/14/11 DWG: PTS 58974 - UNKNOWN Dispatch Group SN retrieved */
/* 09/14/11 DWG: PTS 58991 - Performance revisions.*/

SET NOCOUNT ON

	DEClARE @TH2 TABLE  (SN INT, 
					DTSent DATETIME, 
					DispatchGroupSN INT
				)

	DECLARE @MaxMessagesPassOne INT
	DECLARE @UNKNOWN_DispatchGroupSN int

	SELECT @UNKNOWN_DispatchGroupSN = SN 
	FROM tblDispatchGroup (NOLOCK)
	WHERE Name = ' UNKNOWN'

	SET @MaxMessagesPassOne = ISNULL(@MaxMessages, 0) * 1.2

	INSERT INTO @TH2 (SN,
			DTSent,
			DispatchGroupSN)
		SELECT MSG.SN,
			DTSent,
			ISNULL(CurrentDispatcher, @UNKNOWN_DispatchGroupSN)
		FROM tblHistory (NOLOCK) 
			INNER JOIN tblMessages MSG (NOLOCK) ON MSG.SN = tblHistory.MsgSN  --For DTSent
			INNER JOIN tblDrivers (NOLOCK) ON tblDrivers.SN = DriverSN --For Dispatch Group
		WHERE tblHistory.DriverSN = @DriverSN

	IF ISNULL(@MaxMessages, 0) > 0
		SET ROWCOUNT @MaxMessagesPassOne

	SELECT TH2.SN, TH2.DispatchGroupSN
		FROM  @TH2 TH2
		ORDER BY DTSent DESC, TH2.SN DESC 
			
	-- Restore the rowcount.
	SET ROWCOUNT 0

GO
GRANT EXECUTE ON  [dbo].[tm_get_drv_hist_help] TO [public]
GO
