SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

----------------------------------
--- TMT AMS from TMWSYSTEMS
---	CHANGED 8/26/2015 KS (PTS:93293)  -- Once the asset has been transferred , it is not transferred for the same leg again
--- CHANGED 5/21/2015 MB (DT: 1101)  -- worked to return a valid dataset for use by TMT
--- CREATED 4/16/2015 MC (DT: 1101)   -- Mindy reworked the system to only be much faster used a CTE
----------------------------------
create PROC [dbo].[TMT_ASSET_TRANSFER_SP] @DAYSBACK INTEGER = NULL
AS
BEGIN

SET NOCOUNT ON

SET @DAYSBACK = ISNULL(@DAYSBACK, 4)
DECLARE @LOWDATE DATETIME
DECLARE @HIGHDATE DATETIME
SET @HIGHDATE = CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, GETDATE())))
SET @LOWDATE = CONVERT(DATETIME, FLOOR(CONVERT (FLOAT, @HIGHDATE))
- @DAYSBACK);

-- this part creates the history records

DECLARE @INSERT_TMT_ASSETTRANSFERHISTORY TABLE
(
LGH_NUMBER int ,
TRACTOR varchar(8) ,
DRIVER varchar(8),
TRAILER varchar(8),
ASGN_DATE datetime,
ASGN_ENDDATE datetime,
ASGN_STATUS varchar(6)
)

;WITH	MISSING_AA_RECORDS ( LGH_NUMBER, ASGN_TYPE, ASGN_DATE, ASGN_ID, ASGN_ENDDATE, ASGN_STATUS )
AS (
SELECT A.LGH_NUMBER ,
A.ASGN_TYPE ,
A.ASGN_DATE ,
A.ASGN_ID ,
A.ASGN_ENDDATE ,
A.ASGN_STATUS
FROM ASSETASSIGNMENT A
LEFT JOIN TMT_ASSETTRANSFERHISTORY ATH
ON
A.LGH_NUMBER = ATH.LGH_NUMBER
AND A.ASGN_DATE = ATH.ASGN_DATE
WHERE A.ASGN_DATE >= @LOWDATE
AND A.ASGN_DATE <= @HIGHDATE
AND ASGN_STATUS <> 'PLN'
AND ATH.LGH_NUMBER IS NULL
)
INSERT INTO @INSERT_TMT_ASSETTRANSFERHISTORY
( LGH_NUMBER ,
TRACTOR ,
DRIVER ,
TRAILER ,
ASGN_DATE ,
ASGN_ENDDATE,
ASGN_STATUS
)
SELECT PIVOTTABLE.LGH_NUMBER ,
PIVOTTABLE.[TRC] ,
PIVOTTABLE.[DRV] ,
PIVOTTABLE.[TRL] ,
PIVOTTABLE.ASGN_DATE ,
PIVOTTABLE.ASGN_ENDDATE,
PIVOTTABLE.ASGN_STATUS
FROM (
SELECT LGH_NUMBER ,
ASGN_TYPE ,
ASGN_DATE ,
ASGN_ENDDATE ,
ASGN_ID,
ASGN_STATUS
FROM MISSING_AA_RECORDS
WHERE ASGN_ID IS NOT NULL
) AS DATATABLE PIVOT ( MAX(ASGN_ID) FOR ASGN_TYPE IN ( [TRC],
[DRV], [TRL] ) ) PIVOTTABLE
LEFT JOIN TMT_ASSETTRANSFERHISTORY TAH
ON
PIVOTTABLE.LGH_NUMBER = TAH.LGH_NUMBER
AND PIVOTTABLE.ASGN_DATE = TAH.ASGN_DATE
AND PIVOTTABLE.TRC = TAH.TRACTOR
AND PIVOTTABLE.TRL = TAH.TRAILER
AND PIVOTTABLE.DRV = TAH.DRIVER
AND TAH.LGH_NUMBER IS NULL
ORDER BY PIVOTTABLE.LGH_NUMBER

INSERT TMT_ASSETTRANSFERHISTORY
(
LGH_NUMBER ,
TRACTOR ,
DRIVER ,
TRAILER ,
ASGN_DATE ,
ASGN_ENDDATE
)
SELECT
LGH_NUMBER ,
TRACTOR ,
DRIVER ,
TRAILER ,
ASGN_DATE ,
ASGN_ENDDATE
FROM @INSERT_TMT_ASSETTRANSFERHISTORY

SET NOCOUNT OFF

SELECT 		ta.LGH_NUMBER ,
ta.TRACTOR ,
tp.TRC_AMS_TYPE ,
ta.DRIVER ,
ta.TRAILER ,
tc.TRL_AMS_TYPE ,
ta.ASGN_DATE ,
CASE WHEN ta.ASGN_STATUS = 'CMP' THEN ta.ASGN_ENDDATE
ELSE NULL
END AS ASGN_ENDDATE ,
tp.TRC_OWNER,
tp.TRC_DIVISION ,
tp.TRC_FLEET ,
tp.TRC_COMPANY ,
ta.ASGN_STATUS AS UNITSTATUS
FROM @INSERT_TMT_ASSETTRANSFERHISTORY ta
LEFT JOIN TRACTORPROFILE tp on ta.TRACTOR = tp.TRC_NUMBER
LEFT JOIN TRAILERPROFILE tc on ta.TRAILER = tc.TRL_NUMBER
LEFT JOIN PAYTO p on tp.TRC_OWNER = P.PTO_ID
END


GO
GRANT EXECUTE ON  [dbo].[TMT_ASSET_TRANSFER_SP] TO [public]
GO
