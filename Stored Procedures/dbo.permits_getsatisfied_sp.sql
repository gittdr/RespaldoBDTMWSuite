SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[permits_getsatisfied_sp] (@mov_number int, @lgh_number int, @startdate as datetime, @enddate as datetime, @drv1 varchar(13), @drv2 varchar(13), @trc varchar(13), @trl1 varchar(13), @trl2 varchar(13))
AS
	/*
	This proc returns all permits required for a move as well as the permits that satisfy the requirements
	*/

	DECLARE @PermitsRequired	int
	DECLARE @PermitsFound		int


/* PTS 29502 JLB moved the table creates to the beginning of the procedure to conform to standards 
   and also added NULL attribute to them
*/
	CREATE TABLE #PermitsSatisfied (
		[PR_ID] [int] NOT NULL,
		[PM_ID] [int]  NOT NULL,
		[mov_number] [int] NULL,
		[lgh_number] [int] NULL,
		[asgn_type] [varchar] (6) NULL,
		[PR_Default] [char] (1) NULL,  
		[P_ID] [int] NULL,
		[asgn_id] [varchar] (13) NULL,
		[P_Status] [varchar] (6) NULL, 
		[P_Permit_Number] [varchar] (50) NULL,
		[PSB_ID] [int] NULL
	) 
	
	CREATE TABLE #TempAssetAssignment (
		[asgn_type] [varchar] (6) NULL,
		[asgn_id] [varchar] (13) NULL 
	) 
--end 29502

	--Do not bother to determine permit requirements if no assets are assigned
	IF @drv1 = 'UNKNOWN' AND @drv2 = 'UNKNOWN' AND @trc = 'UNKNOWN' AND @trl1 = 'UNKNOWN' AND @trl2 = 'UNKNOWN' BEGIN
		--Return resultset
		SELECT PermitsRequired = 0, PermitsFound = 0, PermitsWereChecked = 0
		RETURN 0
	END
	
	INSERT INTO #TempAssetAssignment
	VALUES( 'DRV', @drv1)
	
	INSERT INTO #TempAssetAssignment
	VALUES( 'DRV', @drv2)

	INSERT INTO #TempAssetAssignment
	VALUES( 'TRC', @trc)

	INSERT INTO #TempAssetAssignment
	VALUES( 'TRL', @trl1)

	INSERT INTO #TempAssetAssignment
	VALUES( 'TRL', @trl2)

	--Get Permits required
	SELECT @PermitsRequired = count(*)
	FROM        Permit_Requirements 
	WHERE    (mov_number = @mov_number) AND (lgh_number = @lgh_number or lgh_number = 0)
			AND (PR_Default <> 'X')
	
	--Permit that directly satisfies requirement
	INSERT INTO #PermitsSatisfied
	SELECT    PR.PR_ID, PR.PM_ID, PR.mov_number, PR.lgh_number, PR.asgn_type, PR.PR_Default, P.P_ID, P.asgn_id, P.P_Status, 
						P.P_Permit_Number, 0
	FROM        Permit_Requirements PR INNER JOIN
						Permits P ON PR.mov_number = P.mov_number AND PR.PM_ID = P.PM_ID
	WHERE    (PR.mov_number = @mov_number) AND (PR.lgh_number = @lgh_number or PR.lgh_number = 0) 
			 AND (PR.PR_Default <> 'X')
			 AND (P.P_Valid_From <= @startdate AND 
                     (P.P_Valid_To >= @enddate))


	--Permit that directly satisfies requirement asset type
	INSERT INTO #PermitsSatisfied
	SELECT    PR.PR_ID, PR.PM_ID, PR.mov_number, PR.lgh_number, PR.asgn_type, PR.PR_Default, P.P_ID, P.asgn_id, P.P_Status, 
						P.P_Permit_Number, 0
	FROM        Permits P INNER JOIN
						#TempAssetAssignment AA ON P.asgn_id = AA.asgn_id INNER JOIN
						Permit_Requirements PR ON AA.asgn_type = PR.asgn_type AND 
						P.asgn_type = PR.asgn_type AND P.PM_ID = PR.PM_ID
	WHERE    (PR.mov_number = @mov_number) AND (PR.lgh_number = @lgh_number or PR.lgh_number = 0)
			 AND (PR.PR_Default <> 'X')
			 AND (P.P_Valid_From <= @startdate AND 
                     (P.P_Valid_To >= @enddate))




	--Permit that indirectly satisfies requirement for movement
	INSERT INTO #PermitsSatisfied
	SELECT    PR.PR_ID, PR.PM_ID, PR.mov_number, PR.lgh_number, PR.asgn_type, PR.PR_Default, P.P_ID, P.asgn_id, 
	                     P.P_Status, P.P_Permit_Number, PSB.PSB_ID
	FROM        Permit_Requirements PR INNER JOIN
	                     Permit_Satisfied_By PSB ON PR.PM_ID = PSB.PM_ID INNER JOIN
	                     Permits P ON PSB.PM_ID_Satisfied_By = P.PM_ID AND PR.mov_number = P.mov_number
	WHERE    (PR.mov_number = @mov_number) AND (PR.lgh_number = @lgh_number or PR.lgh_number = 0)
			 AND (PR.PR_Default <> 'X')
			 AND (P.P_Valid_From <= @startdate AND 
                     (P.P_Valid_To >= @enddate))


		--Permit that indirectly satisfies requirement asset type
	INSERT INTO #PermitsSatisfied
	SELECT    PR.PR_ID, PR.PM_ID, PR.mov_number, PR.lgh_number, PR.asgn_type, PR.PR_Default, P.P_ID, P.asgn_id, 
	                     P.P_Status, P.P_Permit_Number, PSB.PSB_ID
	FROM        Permit_Satisfied_By PSB INNER JOIN
	                     Permit_Requirements PR ON PSB.PM_ID = PR.PM_ID INNER JOIN
	                     Permits P INNER JOIN
	                     #TempAssetAssignment AA ON P.asgn_id = AA.asgn_id ON PSB.PM_ID_Satisfied_By = P.PM_ID AND 
	                     PR.asgn_type = AA.asgn_type AND PR.asgn_type = P.asgn_type
	WHERE    (PR.mov_number = @mov_number) AND (PR.lgh_number = @lgh_number or PR.lgh_number = 0)
			 AND (PR.PR_Default <> 'X')
			 AND (P.P_Valid_From <= @startdate AND 
                     (P.P_Valid_To >= @enddate))

	SELECT @PermitsFound = count(DISTINCT PR_ID) FROM #PermitsSatisfied  
	
	--Return resultset
	SELECT PermitsRequired = @PermitsRequired, PermitsFound = @PermitsFound, PermitsWereChecked = 1
	--SELECT * FROM #PermitsSatisfied  
GO
GRANT EXECUTE ON  [dbo].[permits_getsatisfied_sp] TO [public]
GO
